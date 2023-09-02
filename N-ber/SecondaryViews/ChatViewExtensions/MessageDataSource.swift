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
    
    //MARK: - Cell top labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 { // We will say if in this part toward section can be divided to three without any leftovers, that it means this is every third message and we want to show our title
            
            let showLoadMore = false
            let text = showLoadMore ? "Önceki mesajlarınız için kaydırın" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.systemGray2
            
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    // Cell bottom label
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.time() : ""  // This is the status of message we want to show only for the last one because if this message was read or send, it means the rest of them was also read or send. And there is no point of saying that another user has read every messages
            
            return NSAttributedString(string: status, attributes: [.font: UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.systemGray2])
        }
        return nil
    }
    
    // message bottom label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.systemGray2
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
}
