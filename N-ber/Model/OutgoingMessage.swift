//
//  OutgoingMessage.swift
//  N-ber
//
//  Created by Seyma on 31.08.2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0, memberIds: [String]) {
        
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSent
        
        if text != nil {
            // send textMessage
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        //TODO: send push notification
        //TODO: update recent
        
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String]) { // the task of this func will be simply to save these to our own and to save these to our firebase for each user
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
        
    }
    
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    
    message.message = text
    message.type = kText
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds) // we call this function and we pass our message and sendTextMessage function.
    
}
