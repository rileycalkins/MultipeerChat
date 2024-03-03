//
//  ChatroomView.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/27/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI
import PhotosUI
import Photos

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}

struct ChatroomView: View {
    let companion: CompanionMP
    var chatroomVM: ChatroomViewModel
    @State var selectedPhotos: [PhotosPickerItem] = []
    @State var presentingPicker: Bool = false
    var maxPhotosCount: Int = 4
    @State var processedImages: [UIImage] = []
    
    
    init(multipeerUser: CompanionMP) {
        self.companion = multipeerUser
        chatroomVM = ChatroomViewModel(peer: multipeerUser)
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            @Bindable var chatroomVMBindable = chatroomVM
            messagesListView
            horizontalMessagePhotoPicker
            HStack {
                TextField("Message", text: $chatroomVMBindable.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxHeight: CGFloat(60))
                    .onSubmit {
                        sendMessage()
                    }
                    .disabled(!processedImages.isEmpty)
                if chatroomVM.messageText.isEmpty {
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: maxPhotosCount, selectionBehavior: .continuousAndOrdered) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                    }.photosPickerAccessoryVisibility(.visible, edges: .all)
                }
                Button("", systemImage: !chatroomVM.messageText.isEmpty || !processedImages.isEmpty ? "paperplane.circle.fill" : "paperplane.circle") {
                    sendMessage()
                }.foregroundStyle(!chatroomVM.messageText.isEmpty || !processedImages.isEmpty ? .blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                    .font(.largeTitle)
                    .disabled(chatroomVM.messageText.isEmpty && processedImages.isEmpty)
            }
            .frame(maxHeight: CGFloat(50))
            .padding(.horizontal)
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let uiImage = chatroomVM.companion.picture {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: SessionManager.shared.getMutualSession(with: chatroomVM.companion.mcPeerID) != nil ? "wifi.circle.fill" : "wifi.exclamationmark.circle.fill")
                                .foregroundStyle(SessionManager.shared.getMutualSession(with: chatroomVM.companion.mcPeerID) != nil ? .green : .red)
                                .symbolEffect(.pulse)
                                .offset(x: 10, y: 4)
                                .background {
                                    Circle()
                                        .fill(.white)
                                        .offset(x: 10, y: 4)
                                }
                        }
                }
            }
        }
        .navigationTitle(self.chatroomVM.companion.mcPeerID.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedPhotos) { oldValue, newValue in
                if newValue.count == 0 {
                    processedImages = []
                    return
                } else {
                    processImages()
                    return
                }
            }
            .onAppear() {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    self.chatroomVM.authorizationStatus = status
                }
                self.chatroomVM.loadInitialMessages()
            }
    }
    
    var messagesListView: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(chatroomVM.messages, id: \.id) { msg in
                    self.getMessageView(message: msg)
                        .listRowSeparator(.hidden)
                }
            }.scrollDismissesKeyboard(.immediately)
                .listStyle(.plain)
                .frame(width: UIScreen.screenWidth)
                .onAppear {
                    withAnimation {
                        scrollView.scrollTo(self.chatroomVM.messages.last?.id, anchor: .top)
                    }
                    
                }
        }
    }
    
    var horizontalMessagePhotoPicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(processedImages.indices, id: \.self) { index in
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: maxPhotosCount, selectionBehavior: .ordered) {
                        Image(uiImage: processedImages[index])
                            .resizable()
                            .frame(width: 80, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay(alignment:.topTrailing) {
                                Image(systemName: "arrow.up.forward")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(-10))
                                    .padding(8)
                                    .opacity(0.7)
                            }
                            .overlay(alignment: .bottomLeading) {
                                Image(systemName: "arrow.down.backward")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(-10))
                                    .padding(8)
                                    .opacity(0.7)
                            }
                    }
                }
            }
        }.frame(height: processedImages.isEmpty ? 0 : 100)
        .contentMargins(20)
    }
    
    func sendMessage() {
        if processedImages.isEmpty {
            self.chatroomVM.sendTextMessage()
        } else {
            for image in processedImages {
                self.chatroomVM.sendImageMessage(image: image)
            }
            self.processedImages = []
            self.selectedPhotos = []
        }
    }
    
    func processImages() {
        processedImages = []
        Task {
            for image in selectedPhotos {
                if let image = await pickerImg(pickerPic: image), let uiImage = await image.getUIImage(newSize: CGSize(width: 100, height: 130)) {
                    DispatchQueue.main.async {
                        processedImages.append(uiImage)
                    }
                }
            }
        }
    }
    
    func pickerImg(pickerPic: PhotosPickerItem) async -> Image? {
        do {
            guard let photo = try await pickerPic.loadTransferable(type: Image.self) else {
                return nil
            }
            return photo
        } catch {
            print("Error loading image to transferrable")
            return nil
        }
    }
    
    func getMessageView(message: MPMessage) -> AnyView {
        if let image = UIImage(data: message.data) {
            return AnyView(PeerImageMessageView(messageImage: image, isCurrentUser: chatroomVM.isCurrentUser(message: message), userUIImage: chatroomVM.companion.picture))
        } else if let text = String.init(data: message.data, encoding: .utf8) {
            return AnyView(PeerTextMessageView(message: text, isCurrentUser: chatroomVM.isCurrentUser(message: message), userUIImage: chatroomVM.companion.picture))
        } else {
            return AnyView(EmptyView())
        }
    }
}
