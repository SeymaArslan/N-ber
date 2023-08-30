//
//  MKMessage.swift
//  N-ber
//
//  Created by Seyma on 30.08.2023.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
  
    var status: String
    var readDate: Date
    
    init(message: String) {
        
    }
}

