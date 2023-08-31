//
//  RealmManager.swift
//  N-ber
//
//  Created by Seyma on 31.08.2023.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() {}
    
    // T basically means that we can pass anything as long as it conforms to object protocol and then we are going to have object
    func saveToRealm<T: Object>(_ object: T) {
        do {
            try realm.write{
                realm.add(object, update: .all)
            }
        }
        catch {
            print("Nesnelerin realm kaydı olmadı", error.localizedDescription)
        }
    }
    
    
}
