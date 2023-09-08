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
    
    func downloadSubscribedChannels(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kMemberIds, arrayContains: User.currentId).addSnapshotListener({ (querySnapshot, error) in  // if our userIds inside the memberId, it means we are subscribed to that channel
            
            guard let documents = querySnapshot?.documents else {
                print("Abone kanallarında doküman yok")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(allChannels)
        })
    }
    
    func downloadAllChannels(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        
        //FirebaseReference(.Channel).whereField(kMemberIds, arrayContains: User.currentId).addSnapshotListener({ (querySnapshot, error) in  // subscribe to download all channels, it will again return an array of channels, and this time we dont need to add this listener (channelListener) because this is going to happen only once.. So we dont want to keep listening for any new channels.. What we can implement is we can pull down to refresh if our user wants to do that.. So we dont have to add snapshot listener, instead we will just say get documents
            
            
        FirebaseReference(.Channel).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Bütün kanallar için doküman yok")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
             // we dont want to show the channels that our user is a member of, so if it was in our subscirebe channels, we dont want to add too much here.. So what we want to do is to remove every channel from this array (allChannels) where our user is a member.. so we are going to write a func to do that (removeSubscribedChannels)  **
            allChannels = self.removeSubscribedChannels(allChannels)  // **
            allChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(allChannels)
        }
    }
    
    
    
    //MARK: - Add Update Delete
    func saveChannel(_ channel: Channel) {
        
        do {
         try
            FirebaseReference(.Channel).document(channel.id).setData(from: channel)
        } catch {
            print("Kanal kaydetme hatası ", error.localizedDescription)
        }
    }
    
    
    func deleteChannel(_ channel: Channel) {
        FirebaseReference(.Channel).document(channel.id).delete()
    }
    
    
    
    //MARK: - Helpers
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel] {
        var newChannels: [Channel] = []
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
    
    func removeChannelListener() { // its going to remove our channel at least, and once we leave our application and we dont want to get any notification that something changed
        self.channelListener.remove()
    }
    
}
