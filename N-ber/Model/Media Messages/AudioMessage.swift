//
//  AudioMessage.swift
//  N-ber
//
//  Created by Seyma on 6.09.2023.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {

    var url: URL
    var duration: Float
    var size: CGSize

    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
    
    
    
}
