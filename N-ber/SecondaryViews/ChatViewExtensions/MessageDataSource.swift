//
//  MessageDataSource.swift
//  N-ber
//
//  Created by Seyma on 30.08.2023.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> MessageKit.SenderType {  // sender type waiting 2 value first is id second is username and we are going to return to sender type.. Create MKSender in MessageKiyDefaults struct
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {  // this is message for item at index path in our message collection.. MessageType protocol return messageKit, which is again from our messageKit and it has different kind of messages, text attributes text, photo, video, location, emoji, audio..
        
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {  // this is collectionView and each message is a seperate section. There is not like one section and others are like sales in that section. Each message is a different section
        
        mkMessages.count
    }
    
    
}
