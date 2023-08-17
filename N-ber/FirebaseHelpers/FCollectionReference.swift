//
//  FCollectionReference.swift
//  N-ber
//
//  Created by Seyma on 17.08.2023.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}

