//
//  PhotoMessage.swift
//  N-ber
//
//  Created by Seyma on 5.09.2023.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    
    var url: URL?  // mediaItem is a protocol and every media type message that we want to show in our messageKit, should conform to this protocol, and each of these message should have at least MediaItem parameters/
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "placeHolder")!
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
