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

//MARK: - ChatVC
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
    
    func didTapMessage(in cell: MessageCollectionViewCell) { // burada func sadece harita için fakat text mesajları içinde çağırılıyor bu yüzdeeeen ... let's get access to our cell index
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationItem != nil {  
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                
                navigationController?.pushViewController(mapView, animated: true)
                
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
      guard
        let indexPath = messagesCollectionView.indexPath(for: cell),
        let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
      else {
        print("Failed to identify message when audio cell receive tap gesture")
        return
      }
      guard audioController.state != .stopped else {
        // There is no audio sound playing - prepare to start playing for given audio message
        audioController.playSound(for: message, in: cell)
        return
      }
      if audioController.playingMessage?.messageId == message.messageId {
        // tap occur in the current cell that is playing audio sound
        if audioController.state == .playing {
          audioController.pauseSound(for: message, in: cell)
        } else {
          audioController.resumeSound()
        }
      } else {
        // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
        audioController.stopAnyOngoingPlaying()
        audioController.playSound(for: message, in: cell)
      }
    }
    
    
}



//MARK: - ChannelChatVC
extension ChannelChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                
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
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationItem != nil {
                let mapView = MapViewController()
                mapView.location = mkMessage.locationItem?.location
                
                navigationController?.pushViewController(mapView, animated: true)
                
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        
      guard
        let indexPath = messagesCollectionView.indexPath(for: cell),
        let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
      else {
        print("Failed to identify message when audio cell receive tap gesture")
        return
      }
        
      guard audioController.state != .stopped else {
        audioController.playSound(for: message, in: cell)
        return
      }
        
      if audioController.playingMessage?.messageId == message.messageId {
        if audioController.state == .playing {
          audioController.pauseSound(for: message, in: cell)
        } else {
          audioController.resumeSound()
        }
      } else {
        audioController.stopAnyOngoingPlaying()
        audioController.playSound(for: message, in: cell)
      }
    }
    
    
}
 
