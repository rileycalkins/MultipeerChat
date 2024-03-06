//
//  MPGroupMessage.swift
//  MultipeerChat
//
//  Created by Riley Calkins on 3/6/24.
//  Copyright © 2024 Hesham Salama. All rights reserved.
//

import MultipeerConnectivity
import CoreData

class MPGroupMessage: Identifiable {
    
    private static let tableName = "UserMessageEntity"
    private static let timeKey = "time"
    private static let dataKey = "data"
    private static let idKey = "id"
    private static let senderPeerHashKey = "senderHashValue"
    private static let recipientsPeerHashKey = "recipientsHashValue"
    private static let coreDataHandler = CoreDataHandler(tableName: MPGroupMessage.tableName)
    weak static var delegate: GroupMessageOperations?
    let data: Data
    let unixTime: TimeInterval
    let senderPeerID: UUID
    let receiverPeerIDs: [UUID]
    internal let id: UUID
    
    init(data: Data, unixTime: TimeInterval, senderPeerID: UUID, receiverPeerIDs: [UUID], id: UUID) {
        self.data = data
        self.unixTime = unixTime
        self.senderPeerID = senderPeerID
        self.receiverPeerIDs = receiverPeerIDs
        self.id = id
    }
    
    func saveLocally() {
        guard let managedObject = MPGroupMessage.coreDataHandler.getNewManagedObject() else {
            fatalError("Couldn't save the user data!")
        }
        MPGroupMessage.coreDataHandler.setData(in: managedObject, key: MPGroupMessage.senderPeerHashKey, data: senderPeerID.uuidString)
        MPGroupMessage.coreDataHandler.setData(in: managedObject, key: MPGroupMessage.recipientsPeerHashKey, data: [receiverPeerIDs])
        MPGroupMessage.coreDataHandler.setData(in: managedObject, key: MPGroupMessage.dataKey, data: data)
        MPGroupMessage.coreDataHandler.setData(in: managedObject, key: MPGroupMessage.timeKey, data: unixTime)
        MPGroupMessage.coreDataHandler.setData(in: managedObject, key: MPGroupMessage.idKey, data: id)
        MPGroupMessage.delegate?.added(message: self)
    }
    
    static func getMutualMessages(between peer1ID: UUID, and peer2ID: UUID, paging: Int? = nil) -> [MPGroupMessage] {
        var messages = [MPGroupMessage]()
        let sortDescriptor = [CoreDataSortDescriptor(key: timeKey, isAscending: true)]
        let predicateStr = "(\(recipientsPeerHashKey) == %@ AND \(senderPeerHashKey) == %@) OR (\(senderPeerHashKey) == %@ AND \(recipientsPeerHashKey) == %@)"
        guard let managedObjects = coreDataHandler.getData(predicate: NSPredicate(format: predicateStr, peer1ID.uuidString, peer2ID.uuidString, peer1ID.uuidString, peer2ID.uuidString), sortDescriptors: sortDescriptor, paging: paging) else {
            return messages
        }
        managedObjects.forEach {
            if let messageData = $0.value(forKey: dataKey) as? Data, 
                let unixTime = $0.value(forKey: timeKey) as? TimeInterval,
                let messageID = $0.value(forKey: idKey) as? UUID,
                let receiversUUIDs = $0.value(forKey: recipientsPeerHashKey) as? [UUID],
//                let receiverUUIDs = UUID(uuidString: receiversHash),
                let senderHash = $0.value(forKey: senderPeerHashKey) as? String,
                let senderUUID = UUID(uuidString: senderHash) {
                messages.append(MPGroupMessage(data: messageData,
                                          unixTime: unixTime,
                                          senderPeerID: senderUUID,
                                          receiverPeerIDs: receiversUUIDs,
                                          id: messageID))
            }
        }
        return messages
    }
    
    static func removeAll() {
        guard let managedObjects = coreDataHandler.getData() else {
            return
        }
        coreDataHandler.remove(managedObjects: managedObjects)
    }
}
