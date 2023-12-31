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
    
    //MARK: - Images
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kFileReference).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers() // bu dosyadaki herhangi bir değişiklikten haberdar olmaycağız
            ProgressHUD.dismiss() // ilerleme gösterimini de kapatmak istiyoruz
            if error != nil {
                print("Fotoğraf yükleme hatası: \(error!.localizedDescription)")
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
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            // get it locally
            print("we have local image")
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(contentsOfFile)
            } else {
                print("Fotoğraf yerel olarak kaydedilemedi.")
                completion(UIImage(named: "MeAvatar"))
            }
                
        } else {
            // download from firebase
            print("Lets get from Firebase")
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        // save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    } else {
                        print("Veritabanında belge yok")
                        completion(nil)
                    }
                }
            }
            
        }

    }
    
    
    //MARK: - Video
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kFileReference).child(directory)

        var task: StorageUploadTask!
        
        task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers() // bu dosyadaki herhangi bir değişiklikten haberdar olmaycağız
            ProgressHUD.dismiss() // ilerleme gösterimini de kapatmak istiyoruz
            
            if error != nil {
                print("Video yükleme hatası: \(error!.localizedDescription)")
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
    
    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if fileExistsAtPath(path: videoFileName) {
            completion(true, videoFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            
            downloadQueue.async {
                let data = NSData(contentsOf: videoUrl!)
                if data != nil {
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)  // save locally
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                } else {
                    print("Veritabanında belge yok.")
                }
            }
        }

    }
    
    
    //MARK: - Audio
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        let fileName = audioFileName + ".m4a"
        
        let storageRef = storage.reference(forURL: kFileReference).child(directory)

        var task: StorageUploadTask!
        
        if fileExistsAtPath(path: fileName) {
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { (metadata, error) in
                    
                    task.removeAllObservers() // bu dosyadaki herhangi bir değişiklikten haberdar olmaycağız
                    ProgressHUD.dismiss() // ilerleme gösterimini de kapatmak istiyoruz
                    
                    if error != nil {
                        print("Ses yükleme hatası: \(error!.localizedDescription)")
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
                
            } else {
                print("Hiçbir şey yüklenemedi (ses)")
            }
        }
    }

    class func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
 
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        
        if fileExistsAtPath(path: audioFileName) {
            completion(audioFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            
            downloadQueue.async {
                let data = NSData(contentsOf: URL(string: audioLink)!)
                if data != nil {
                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)  // save locally
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                } else {
                    print("Veritabanında ses belgesi yok.")
                }
            }
        }

    }
    
    
    //MARK: - Save Locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docURL = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docURL, atomically: true)
    }
    
}


//MARK: - Helpers
func fileInDocumentsDirectory(fileName: String) -> String { // yerel dosyamız için bir yol elde etmek istiyoruz
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: filePath)
}
