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
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    
    private init() {}
    
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {  // documentId will be our userId and collectionId will be our chatRoomId and lastMessageDate will be last message state, this one we need to calculate
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDate, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshpt, error) in  // and then our firebase we ask to keep listening and we create this newChatListener variable.. So we want to stop listening whenever we leave our chatRoom. So we listen for any changes in our database with the specific parameters
            
            guard let snapshot = querySnapshpt else { return }
            
            for change in snapshot.documentChanges { // and if there is a change, we check
                if change.type == .added { // if it was an addition to our database and then we try to create
                    let result = Result { // a local message from it
                        try? change.document.data(as: LocalMessage.self)
                    }
                
                    switch result { // if it was successful, we save it to our Realm otherwise we print an error
                    case .success(let messageObject):
                        if let message = messageObject {
                            RealmManager.shared.saveToRealm(message)
                        } else {
                            print("Belge mevcut değil.")
                        }
                    case .failure(let error):
                        print("Local mesajlar docode edilirken hata oluştu, \(error.localizedDescription)")
                    }
                }
            }
        })
    }
    
    func checkForOldChats(_ documentId: String, collectionId: String) {
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshpt, error) in
            guard let documents = querySnapshpt?.documents else {
                print("Eski sohbetlerin belgesi bulanamadı.")
                return
            }
            
            // we want to save them to our realm and then the database will be updated and our user can see them. So we grab everything to convert it to local message and we save it to our realm
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
            
        }
    }
    
    //MARK: - Add, update, delete
    func addMessage(_ message: LocalMessage, memberId: String){
        do {
            let _ = try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)  // we don't need a variable name here eequls to try and we're going to try Firebase, we want a message so we access the messages, then we want to create a document and the path our document will be the memberId. So each message will have a subfolder called document, which will have the memberId of each user, and then we will have a collection and path to the collection, the name is going to be our chatroom, ao each message has a user folder, each user has the chatrooms folder and each chatroom is going to have a specific message. So this is going to be our hierarchy. So the collection is going to be our message '.' chatRoomId here. And then we can create a document which has our message.id as the name. And all I haveto do is say setData(from:) -> throw and may throw and the incredible thing we are going to pass is our 'message' since we are confirming to the protocol. It is going to take it and convet it to, json
        } catch {
            print("Mesaj kaydedilirken hata oluştu ", error.localizedDescription)
        }
    }
    
    func removeListeners() {
        self.newChatListener.remove()
       // self.updatedChatListener.remove()
    }
    
    
}
