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
    
    func addRecent(_ recent: RecentChat) {
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        } catch {
            print("Son sohbet kaydedilirken hata oluştu -> ", error.localizedDescription)
        }
    }
}
