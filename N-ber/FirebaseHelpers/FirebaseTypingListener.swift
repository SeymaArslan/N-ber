//
//  FirebaseTypingListener.swift
//  N-ber
//
//  Created by Seyma on 4.09.2023.
//

import Foundation
import Firebase

class FirebaseTypingListener {
    
    static let shared = FirebaseTypingListener()
    var typingListener: ListenerRegistration!
    
    private init() {}
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void){
        
        typingListener = FirebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {  // if snapshot doesn't exist, it means we just started our chat for first time and there is no such thing as this chatRoom in our typing area
                completion(false)
                FirebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])  // setData(<#T##documentData: [String : Any]##[String : Any]#>) -> we want to set data, and since we don't know what other users Id is or if we want to set other user typing or no, initially we are going to said only that our user is typing. So we'll pass a key value pairs here
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        FirebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
    
}
