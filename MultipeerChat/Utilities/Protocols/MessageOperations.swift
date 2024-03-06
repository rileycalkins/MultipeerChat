//
//  MessageAdded.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//

protocol MessageOperations: AnyObject {
    func added(message: MPMessage)
}

protocol GroupMessageOperations: AnyObject {
    func added(message: MPGroupMessage)
}
