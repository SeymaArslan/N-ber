//
//  MessageLayoutDelegate.swift
//  N-ber
//
//  Created by Seyma on 30.08.2023.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesLayoutDelegate { // basically we are going to see the information like this top label, the bottom label, the last one read status, so all these things are part of our layout delegate and also on the top part here, which we are going to implement when we need to refresh
    
    //MARK: - Cell top label
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section % 3 == 0 {
            //TODO: set different size for pull to reload
            
            return 18
        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    //MARK: - Message bottom label
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return indexPath.section != mkMessages.count - 1 ? 10 : 0  // if this is the last section, so we check how many messages we have since it's a 0 based, we deduct one from it. and if the section is the last section, so we are here, we want to return 10 points, otherwise we want to 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
    
}
