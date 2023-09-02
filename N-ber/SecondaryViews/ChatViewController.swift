//
//  ChatViewController.swift
//  N-ber
//
//  Created by Seyma on 29.08.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView // this is the input bar of our message review you will see once we start using it
import Gallery // this will be used to choose an image picture, image that we want to send or a video
import RealmSwift

class ChatViewController: MessagesViewController {

    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let refreshController = UIRefreshControl()
    
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = []
    
    //MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil) // so initialize our super view of our messenger messages, your controller as well
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) { // this should get read of our errors
        super.init(coder: coder)
    }

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
       configureMessageInputBar()
    }
    
    //MARK: - Configurations
    private func configureMessageCollectionView() { // set all delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // the reason we want automatically scrolls to the last message
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController  // this is the display of the spins after the user pulls down the chatView
        
    }

    private func configureMessageInputBar() { // message input power we get from our message
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus.viewfinder")
        attachButton.setSize(CGSize(width : 30, height: 30), animated: false)
        attachButton.tintColor = .systemOrange
        attachButton.onTouchUpInside { item in
            print("ekle butonuna basıldı")
        }
        
        // microphone
        micButton.image = UIImage(systemName: "mic.fill")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.tintColor = .systemOrange
        
        // add gesture recognizer
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false) // control to constraints
        
        messageInputBar.inputTextView.isImagePasteEnabled = false // don't want to for the user to be able to paste the image inside our cell here, copy text but can't copy image
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
    }
    
    //MARK: - Actions
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
        
    }
    
    
    
}
