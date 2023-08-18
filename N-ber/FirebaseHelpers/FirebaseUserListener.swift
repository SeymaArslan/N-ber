//
//  FirebaseUserListener.swift
//  N-ber
//
//  Created by Seyma on 17.08.2023.
//

import Foundation
import Firebase

class FirebaseUserListener {
    static let shared = FirebaseUserListener()

    private init () {
    }
    
    //MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            
            completion(error)
            
            if error == nil {
                
                // send verification email
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email send with error: ", error?.localizedDescription)
                }
                
                // create user and save it
                if authDataResult?.user != nil {
                    
                    let user = User(id: authDataResult!.user.uid ,username: email, email: email, pushId: "", avatarLink: "", status: "Hey there I'm using N-ber")
                    saveUserLocally(user)
                    self.saveUserToFirestore(user)
                }
                
            }
        }
    }
    
    //MARK: - Save users
    func saveUserToFirestore(_ user: User) {
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "adding user")
        }
    }
    
    //MARK: - DownloadUserFromFirebase
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("No document for user")
                return
            }
            let result = Result {
                try? document.data(as: User.self)
            }
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
            
        }
    }
    
}

