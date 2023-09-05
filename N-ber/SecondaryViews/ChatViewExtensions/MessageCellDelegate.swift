//
//  MessageCellDelegate.swift
//  N-ber
//
//  Created by Seyma on 30.08.2023.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser // library that we installed through cocapods

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) { // this is when we are notified that our user has tapped an iamge and REMEMBER, in our case and the picture and the video are both of them as IMAGE.. but for both of them, we want to shoe different func, so for images, we want to show them in a different view that we can inlarge, share etc. for videos we want to open them.. Again in a different view, but to be a video player so we can play and need to check which image is what? So that we can do it based on it's video or audio
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section] // so having an access to this mkMessage, we can check the photo or video items
            
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)  // it doesn't really make sense in this case because we have only 1 image.. and that would be if you want to start from the beginning, it would be zero, otherwise you can put an index here you want
                
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviePlayer.player = player
                
                present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
                
            }
            
        }
    }
}
 
