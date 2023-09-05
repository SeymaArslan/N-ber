//
//  VideoMessage.swift
//  N-ber
//
//  Created by Seyma on 5.09.2023.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(named: "placeHolder")!
        self.size = CGSize(width: 240, height: 240)
    }
}
