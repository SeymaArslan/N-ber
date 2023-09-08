//
//  FirebaseChannelListener.swift
//  N-ber
//
//  Created by Seyma on 8.09.2023.
//

import Foundation
import Firebase

class FirebaseChannelListener {
    
    static let shared = FirebaseChannelListener()  // we are going to create a singleton, we initialize these
    
    var channelListener: ListenerRegistration!  // imported FİrebaseListener -> FIRListenerRegistration -> ListenerRegistration
    
    private init() {}
    
    
    //MARK: - Fetching of our channels
    func downloadUserChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) -> Void) {  // the func just has this code back and returns all the array of channels that belong to out user
        
        channelListener = FirebaseReference(.Channel).whereField(kAdminId, isEqualTo: User.currentId).addSnapshotListener({ (querySnapshot, error) in  // isEqualTo should be equal to, it should be our currently logged in userId.. So we want to get all the channels where the adminId is our current userId... addSnapshotListener keep getting updates about any changes there
            
            guard let documents = querySnapshot?.documents else {
                print("Kullanıcı kanallarında doküman yok")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})  // Kanallarım has more users so it will show on top, kanallar that have more members, so which one is more popular to say
            completion(allChannels)
            
        })
    }
    
    
    //MARK: - Add Update Delete
    func addChannel(_ channel: Channel) {
        
        do {
         try
            FirebaseReference(.Channel).document(channel.id).setData(from: channel)
        } catch {
            print("Kanal kaydetme hatası ", error.localizedDescription)
        }
    }
    
    
}
