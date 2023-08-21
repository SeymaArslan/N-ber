//
//  FileStorage.swift
//  N-ber
//
//  Created by Seyma on 21.08.2023.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kFileReference).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers() // bu dosyadaki herhangi bir değişiklikten haberdar olmaycağız
            ProgressHUD.dismiss() // ilerleme gösterimini de kapatmak istiyoruz
            if error != nil {
                print("image yükleme hatası: \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in // ilerleme yüzdemiz
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
        
    }
    
}

