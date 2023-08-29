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
       
    }


}
