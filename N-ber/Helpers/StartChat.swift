//
//  StartChat.swift
//  N-ber
//
//  Created by Seyma on 23.08.2023.
//

import Foundation
import Firebase

//MARK: - StartChat
func StartChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    return chatRoomId
}

func createRecentItems(chatRoomId: String, users: [User]) {
    
    var membersIdsToCreateRecent = [users.first!.id, users.last!.id]
//    print("Üyelerin oluşturması gereken ", membersIdsToCreateRecent)
    
    FirebaseReference(.Recent).whereField(kChatRoomId, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            membersIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: membersIdsToCreateRecent)
//            print("Güncellenen üyelerin oluşturması gereken ", membersIdsToCreateRecent)
        }
        
        for userId in  membersIdsToCreateRecent {
//            print("Kullanıcı için yeni içerik oluşturuluyor id : ", userId)
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            
            FirebaseRecentListener.shared.addRecent(recentObject)
        }
        
    }
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
 
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSenderId] {
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    return memberIdsToCreateRecent
}


func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    
    return chatRoomId
}

func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
