//
//  ProfileSetupView.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/6/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @Environment(LoginViewModel.self) var loginViewModel : LoginViewModel
    @State private var showErrorAlert = false
    @State private var uiimage = UIImage(named: "defaultProfile")
    @State var photoPickerItem: PhotosPickerItem?
    
    func processImage() {
        Task {
            if let photoPickItem = photoPickerItem, 
                let image = await pickerImg(pickerPic: photoPickItem), 
                let uiImage = await image.getUIImage(newSize: CGSize(width: 150, height: 150)) {
                DispatchQueue.main.async {
                    uiimage = uiImage
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
    
    var body: some View {
        Group {
            @Bindable var loginViewModelBindable = loginViewModel
            VStack(alignment: .center, spacing: 16) {
                PhotosPicker(selection: $photoPickerItem) {
                    DefaultImageConstructor.get(uiimage: uiimage)
                        .peerImageModifier().frame(width: 150.0, height: 150.0)
                }
                TextField("Enter your name here", text: $loginViewModelBindable.name)
                    .background(Color.clear)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        attemptLogin()
                    }
                Button(action: {
                    attemptLogin()
                }) {
                    Text("Continue")
                }
            }.padding(.vertical, -150)
            .alert(isPresented: $loginViewModelBindable.isErrorShown) {
                Alert(title: Text("Error"),
                      message: Text(loginViewModel.errorMessage))
            }
            .onChange(of: photoPickerItem) { oldValue, newValue in
                processImage()
            }
        }
    }
    
    func attemptLogin() {
        self.loginViewModel.attemptRegisteration(image: self.uiimage)
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
    }
}
