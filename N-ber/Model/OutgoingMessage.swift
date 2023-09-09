//
//  OutgoingMessage.swift
//  N-ber
//
//  Created by Seyma on 31.08.2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery  // the video is part of the gallery and now we have access to that

class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0, memberIds: [String]) {
        
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSent
        
        if text != nil {
            // send textMessage
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
//            print("ses gönder ", audio, audioDuration)
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        //TODO: send push notification
        
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        
    }
    
    
    class func sendChannel(channel: Channel, text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        let currentUser = User.currentUser!
        var channel = channel
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSent
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: channel.memberIds, channel: channel)
        }
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: channel.memberIds, channel: channel)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: channel.memberIds, channel: channel)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: channel.memberIds, channel: channel)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: channel.memberIds, channel: channel)
        }
        
        // send push notification
        
        channel.lastMessageDate = Date()
        FirebaseChannelListener.shared.saveChannel(channel)
        
    }
    
    
    class func sendMessage(message: LocalMessage, memberIds: [String]) { // the task of this func will be simply to save these to our own and to save these to our firebase for each user
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
    
    
    class func sendChannelMessage(message: LocalMessage, channel: Channel) { // the task of this func will be simply to save these to our own and to save these to our firebase for each user
        RealmManager.shared.saveToRealm(message)
        FirebaseMessageListener.shared.addChannelMessage(message, channel: channel)
    }
    
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    
    message.message = text
    message.type = kText
    
    if channel != nil {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
    } else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil) {
    
    message.message = "+ Fotoğraf"
    message.type = kPhoto
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName) // so this will save the file locally as well
    
    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in
        
        if imageURL != nil {
            message.pictureUrl = imageURL!
            
            if channel != nil {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
    
}

func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil) {
    
    message.message = "+ Video"
    message.type = kVideo
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { (processedVideo, videoUrl) in
        
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(video: tempPath)
            
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { (imageLink) in
                if imageLink != nil {
                    
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                        
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        if channel != nil {
                            OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
                        } else {
                            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
                        }
                    }
                }
            }
        }
        
    }
}


func sendLocationMessage(message: LocalMessage, memberIds: [String], channel: Channel? = nil) {
    
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "+ Konum"
    message.type = kLocation
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    if channel != nil {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
    } else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}

func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String], channel: Channel? = nil) {
    
    message.message = "+ Sesli mesaj"
    message.type = kAudio
    
    let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
    
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { (audioUrl) in
        
        if audioUrl != nil {
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            
            if channel != nil {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
    
}
