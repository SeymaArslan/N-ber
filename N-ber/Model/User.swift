//
//  User.swift
//  N-ber
//
//  Created by Seyma on 17.08.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable { // Equatable is to control two equal users ne zaman 2 kullanıcı sağlayacağımızı kontrol edeceğiz
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                do{
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from user defaults ", error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
}

func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("error saving user locally ", error.localizedDescription)
    }
    
}

func createDummyUsers() {
    print(" ***** **** **** create dummy users")
    let names = ["Sema Arslan", "Leyla Arslan", "Ece Uzer", "Derya Uğurlu", "Betül Oktem", "Ilgın Azra Aktaş"]
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5 {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = User(id: id, username: names[i], email: "user\(userIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "Durum Yok")
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFirestore(user)
        }
        
        imageIndex += 1
        if imageIndex == 5 {
            imageIndex = 1
        }
    }
    
}
