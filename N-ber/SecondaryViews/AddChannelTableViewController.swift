//
//  AddChannelTableViewController.swift
//  N-ber
//
//  Created by Seyma on 7.09.2023.
//

import UIKit
import Gallery
import ProgressHUD

class AddChannelTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    
    //MARK: - Vars
    var gallery: GalleryController!
    var tapGesture = UITapGestureRecognizer()
    var avatarLink = ""
    var channelId = UUID().uuidString  // so this will be a unique id for our channel
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView() // and this way its going to hide our empty selves
        
        configureGestures()
    }

    
    //MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if nameTextField.text != "" {
            saveChannel()
        } else {
            ProgressHUD.showError("Kanal adı boş!")
        }
    }
    
    
    @objc func avatarImageTap() {
//        print("tap on avatar")
        showGallery()
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Configuration
    private func configureGestures() {
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true // it means our user can interact with our avatar image of you, and the interaction also includes tapping on the avatarImage of you
        avatarImageView.addGestureRecognizer(tapGesture)

    }
    
    private func configureLeftBarButton () {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrowshape.left.fill"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    
    //MARK: - SaveChannel
    private func saveChannel() {
        let channel = Channel(id: channelId, name: nameTextField.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextView.text)
        
        FirebaseChannelListener.shared.addChannel(channel)  // save channel to Firebase
        
        self.navigationController?.popViewController(animated: true)  // dismiss
    }
    
    
    //MARK: - Gallery
    private func showGallery() {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        self.present(gallery, animated: true, completion: nil)
    }
    
    
    //MARK: - Avatars
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.7)! as NSData, fileName: self.channelId)
        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            self.avatarLink = avatarLink ?? ""
        }
    }
    
}


extension AddChannelTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
      
        if images.count > 0 {
            images.first!.resolve(completion: { (icon) in
                if icon != nil {
                    self.uploadAvatarImage(icon!) // upload image
                    
                    self.avatarImageView.image = icon?.circleMasked // set avatar image
                } else {
                    ProgressHUD.showFailed("Fotoğraf seçilmedi!")
                }
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
