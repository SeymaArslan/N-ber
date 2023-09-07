//
//  Channel.swift
//  N-ber
//
//  Created by Seyma on 7.09.2023.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Channel: Codable {
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createdDate = Date()  // ServerTimestamp, which comes with this FirebaseFirestoreSwift, basically, it says if these two values are not set, firebase is going to take and assign a serverTimestamp, which is the current date automatically, so this way we have like EXTRA safety
    @ServerTimestamp var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey { // and this way, once you do like you cannot only take the last message.. if you enabled this thing (CodingKeys) then you have to set all the keys here. No matter if they match or if they don't match the CodingKeys doesn't care about it .. you have to have all of them here
        
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createdDate
        case lastMessageDate = "date"  // from our last message date that we are going to use a date key, everything else is set as the key is the same as our server, if you happen to change something on your server side, its good to come here and change the add value here
    }
}
