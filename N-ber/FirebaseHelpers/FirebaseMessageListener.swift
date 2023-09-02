//
//  FirebaseMessageListener.swift
//  N-ber
//
//  Created by Seyma on 2.09.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    static let shared = FirebaseMessageListener()
    
    private init() {}
    
    //MARK: - Add, update, delete
    func addMessage(_ message: LocalMessage, memberId: String){
        do {
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)  // we don't need a variable name here eequls to try and we're going to try Firebase, we want a message so we access the messages, then we want to create a document and the path our document will be the memberId. So each message will have a subfolder called document, which will have the memberId of each user, and then we will have a collection and path to the collection, the name is going to be our chatroom, ao each message has a user folder, each user has the chatrooms folder and each chatroom is going to have a specific message. So this is going to be our hierarchy. So the collection is going to be our message '.' chatRoomId here. And then we can create a document which has our message.id as the name. And all I haveto do is say setData(from:) -> throw and may throw and the incredible thing we are going to pass is our 'message' since we are confirming to the protocol. It is going to take it and convet it to, json
        } catch {
            print("Mesaj kaydedilirken hata oluştu ", error.localizedDescription)
        }
    }
}
