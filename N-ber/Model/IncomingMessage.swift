//
//  IncomingMessage.swift
//  N-ber
//
//  Created by Seyma on 2.09.2023.
//

import Foundation
import MessageKit
import CoreLocation // because we want to show location messages as well

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController

    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    //MARK: - CreateMessage
    
    func  createMessage(localMessage: LocalMessage) -> MKMessage? { // MKMessage? but this isn't optional because it may fail to convert it into a MKmessage, so we don't want to crush the application, say it's an optional
        
        let mkMessage = MKMessage(message: localMessage)
        
        if localMessage.type == kPhoto {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (image) in
                mkMessage.photoItem?.image = image
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kVideo {
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { (thumbNail) in
                
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { isReadyToPlay, videoFileName in
                    
                    let videoUrl = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: videoFileName))
                    
                    let videoItem = VideoMessage(url: videoUrl)
                    
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)  // this is our main message understands that we are not showing a picture message, but the video, so it will apply this play button on top of the imageView
                }
                mkMessage.videoItem?.image = thumbNail
                self.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kLocation {
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))  // now we have a location message
            
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
            
        }
        
        return mkMessage
    }
}
