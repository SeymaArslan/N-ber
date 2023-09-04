//
//  FirebaseRecentListener.swift
//  N-ber
//
//  Created by Seyma on 26.08.2023.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    // download all the recentChats
    func downloadRecentChatsFromFirestore(completion: @escaping (_ allRecents: [RecentChat]) ->Void ) {
        FirebaseReference(.Recent).whereField(kSenderId, isEqualTo: User.currentId).addSnapshotListener { (querySnapshot, error) in
            var recentChats: [RecentChat] = [] // herhangi bir recent message varsa
            
            // checking querySnapshot
            guard let document = querySnapshot?.documents else {
                print("Son sohbetler için belge yok.")
                return
            }
            
            let allRecents = document.compactMap { (queryDocumentSnapshot) -> RecentChat? in  // create a convert them into a recent chat object because we are getting a dictionary
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecents { // we check which ones have a last message
                if recent.lastMessage != "" { // it means we have some kind of message
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })  // sort them
            completion(recentChats)  // return them
        }
    }
    
    func resetRecentCounter(chatRoomId: String) {
        FirebaseReference(.Recent).whereField(kChatRoomId, isEqualTo: chatRoomId).whereField(kSenderId, isEqualTo: User.currentId).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Son gönderilere ait belge yok")
                return
            }
            let allReccents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            if allReccents.count > 0 { // it means we have at least one item
                self.clearUnreadCounter(recent: allReccents.first!) //and we can call this to reset our recent and then save it *1
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {  // update recent messages
        FirebaseReference(.Recent).whereField(kChatRoomId, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in  // calls and finds all the recent objects that belong to that chatroom
            guard let documents = querySnapshot?.documents else {
                print("Son güncelleme için belge yok")
                return
            }
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recentChat in allRecents { // takes a specific chat specific recent item and updates the last message of it and also the incrementing of the on the counter and the date(the increment counter is only when we need that) in case we need that
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) { // this func doesn't need to have access from outside world.
        var tempRecent = recent
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        self.saveRecent(tempRecent)
    }
    
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent) // *1
    }
    
    func saveRecent(_ recent: RecentChat) {
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        } catch {
            print("Son sohbet kaydedilirken hata oluştu -> ", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
    
}
