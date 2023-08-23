//
//  RecentChat.swift
//  N-ber
//
//  Created by Seyma on 23.08.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds: [String] = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
}
