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
                    
                }
                
            }
        }
    }
    
}

