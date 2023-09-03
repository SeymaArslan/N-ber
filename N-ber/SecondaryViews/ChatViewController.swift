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

    //MARK: - Views
    let leftBarButtonView: UIView = { // this will be our container view and now we are going to you
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true // so it will automatically make it smaller in case if the name is really long, we will adjust the size
        return title
    }()
    
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true // so it will automatically make it smaller in case if the name is really long, we will adjust the size
        return subTitle
    }()
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let refreshController = UIRefreshControl()
    
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    // Listeners
    var notificationToken: NotificationToken?
    
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
        
        configureLeftBarButton()
        configureCustomTitle()
        
        loadChats()
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
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        attachButton.setSize(CGSize(width : 30, height: 30), animated: false)
        attachButton.tintColor = .systemOrange
        attachButton.onTouchUpInside { item in
            print("ekle butonuna basıldı")
        }
        
        // microphone
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.tintColor = .systemOrange
        
        // add gesture recognizer
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false) // control to constraints
        
        messageInputBar.inputTextView.isImagePasteEnabled = false // don't want to for the user to be able to paste the image inside our cell here, copy text but can't copy image
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
    }
    
    private func configureLeftBarButton() { // this function, we are going to make only our icon here as a back button. We don't want to show the back button and the name where we are going to
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)  // this will become our second left power button item
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        titleLabel.text = recipientName
    }
    
    //MARK: - Load chats
    private func loadChats() {
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId) // we say we want our predicate to be where chatRoomId equals to the id that we have
       
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDate, ascending: true)
        //print("\(allLocalMessages.count) mesajımız var.")
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial : // initial means that is the initial loading
                //print("\(self.allLocalMessages.count) mesajımız var.")
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)  // the scrolling to the bottom
            case .update(_, _, let insertions, _) :
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
                
            case .error(let error) :
                print("Eklenirken hata oluştu", error.localizedDescription)
            }
        })
    }
    
    private func insertMessages() { // we want to call is insertMessages plural function that is going to take all the items from allLocalMessages and a cell on based on that item that will insert one by one into our chat view
        
        for message in allLocalMessages {
            insertMessage(message)
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) { // So this function is going just the loop and calls are insert message and this function, we are dividing the tasks so that this function knows only how to take a local message, convert it into a message.. So we want to put every new MKMessage there

        let incoming = IncomingMessage(_collectionView: self) // self because our chatView is a collection view itself so we can pass this to our incoming messages
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        
    }
    
    //MARK: - Actions
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
        
    }
    
    @objc func backButtonPressed() {
        
        //TODO: remove listeners
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Update typing indicator
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "Yazıyor.." : ""
    }
    
}
