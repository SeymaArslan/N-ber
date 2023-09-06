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
    
    var displayMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageMember = 0
    
    var typingCounter = 0  // that is going to listen for our typing changes so we save our typing changes
    
    var gallery: GalleryController!
    
    // Listeners
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName: String = ""
    var audioDuration: Date!
    
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
        
        navigationItem.largeTitleDisplayMode = .never // sohbet ekranında daha fazla mesaj gör bölümünde bir tasarım hatası vardı. sebebi önceki sohbetler ekranında başlığımızın large olması ve sohbet alanını çektiğimizde o aynı large alanını devam ettirmesi bu yüzden kod satırını ekledik
        
        createTypingObserver()
        
        configureLeftBarButton()
        configureCustomTitle()
        
        configureMessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()

        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
        
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
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }

    private func configureMessageInputBar() { // message input power we get from our message
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        attachButton.setSize(CGSize(width : 30, height: 30), animated: false)
        attachButton.tintColor = .systemOrange
        attachButton.onTouchUpInside { item in
            
            self.actionAttachMessage()
        }
        
        // microphone
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.tintColor = .systemOrange
        
        micButton.addGestureRecognizer(longPressGesture)  // this way whenever we long press our micButton now, our func, which doesn't exist yet will be called
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false) // control to constraints
        
        updateMicButtonStatus(show: true) // update microphone button is right here when we initialize our microphone button, because at the beginning we want to see only microphpne. When we open our chatView, the text field is empty, we want to show this button
        
        messageInputBar.inputTextView.isImagePasteEnabled = false // don't want to for the user to be able to paste the image inside our cell here, copy text but can't copy image
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
    }
    
    func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
            messageInputBar.sendButton.setTitleColor(UIColor.systemOrange, for: .normal)
        }
    }
    
    private func configureLeftBarButton() { // this function, we are going to make only our icon here as a back button. We don't want to show the back button and the name where we are going to
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "arrowshape.left.fill"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.systemOrange
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

        if allLocalMessages.isEmpty{ // **
            checkForOldChats()
        }
        
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
    
    // İf our user decides to change the device or lost the device, will replace it with a new one. İf the user logs in on a different device, the local database will be empty.. And the idea is, of course, every time we open our chatView you in case if our local database is empty, we want to check if there are any old chats on a cloud so we can download them and put them in our local database -> listenForNewChats and checkForOldChats .. allLocalMessages will be zero or the array will be empty, we wamt tp just in case to check if there are any old messages **
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats(){
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    
    //MARK: - Insert messages
    private func listenForReadStatusChange() {
        FirebaseMessageListener.shared.listenForReadStatusChange(User.currentId, collectionId: chatId) { updatedMessage in
            if updatedMessage.status != kSent {
                self.updatedMessage(updatedMessage)
            }
        }
    }
    
    private func insertMessages() { // we want to call is insertMessages plural function that is going to take all the items from allLocalMessages and a cell on based on that item that will insert one by one into our chat view
        
        maxMessageNumber = allLocalMessages.count - displayMessagesCount  //we want to show another 12 messges and then another 12,.. etc   oldest---------------min------>maxLatest show min - maxLatest                             oldest----- min------>maxLatest min------>maxLatest min------>maxLatest
        minMessageMember = maxMessageNumber - kNumberOfMessages
        
        if minMessageMember < 0 {  // we said our main message number equals to zero and this way we will never get a negative number there, it will always the smallest value it can have is going to be always zero
            minMessageMember = 0
        }
        
        for i in minMessageMember ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
        
//        for message in allLocalMessages {
//            insertMessage(message)
//        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) { // So this function is going just the loop and calls are insert message and this function, we are dividing the tasks so that this function knows only how to take a local message, convert it into a message.. So we want to put every new MKMessage there

        if localMessage.senderId != User.currentId { // it means this is an incoming message
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self) // self because our chatView is a collection view itself so we can pass this to our incoming messages
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayMessagesCount += 1
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageMember = maxMessageNumber - kNumberOfMessages
        
        if minMessageMember < 0 { // this case, we will never have that negative number
            minMessageMember = 0
        }
        
        for i in (minMessageMember ... maxMessageNumber).reversed() { // we add the message old message, it should be at the index zero of our array (func of insertMessage)
            
            insertOlderMessage(allLocalMessages[i])
            
        }
        
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {

        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayMessagesCount += 1
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        if localMessage.senderId != User.currentId && localMessage.status != kRead {
            FirebaseMessageListener.shared.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recipientId])
        }
    }
    
    
    //MARK: - Actions
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, audioDuration: audioDuration, memberIds: [User.currentId, recipientId])
        
    }
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func actionAttachMessage() {
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Kamera", style: .default) { (alert) in

            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Galeri", style: .default) { (alert) in
            self.showImageGallery(camera: false)

        }
        
        let shareLocation = UIAlertAction(title: "Konum", style: .default) { (alert) in
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLocation)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Kapat", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
            
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    //MARK: - Update typing indicator
    func createTypingObserver() {
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        typingCounter += 1
        
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)  // and this way we are saving that our current user is typing, whenever we want to update our indicator
        
        // also we want to said that our user is no longer typing after some amount of time because, for example, when you start typing and at some point you will stop typing or do nothing, which basically means you are stoppped typing, we want this to automatically be updated on our firebase. So our user, even if the user stops doing anyting, we want our code to still update the typing that the user has stopped.. So we are going to put some timer here and call a specific function that is going to stop our typing after x amount of seconds
        
        //DispatchQueue.main.asyncAfter(deadline: <#T##DispatchTime#>, execute: <#T##() -> Void#>)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "Yazıyor.." : ""
    }
    
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageMember)  // load earlear messages
                
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
    
    
    //MARK: - Update read message status
    private func updatedMessage(_ localMessage: LocalMessage) {
        // the first thing we want to do is to find that message
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                
                RealmManager.shared.saveToRealm(localMessage)
                
                if mkMessages[index].status == kRead {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - Helpers
    private func removeListeners() {
        FirebaseTypingListener.shared.removeTypingListener()
        // we want to remove our message listener because we don't want to listen for any new messages when we leave the chatRoom
        FirebaseMessageListener.shared.removeListeners()
    }
    
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date() // The scenario is, we started brandnew chat there are no messages, so that last this thing will be nil (allLocalMessages.last?.date) because there are no messages in our local messages, so then we want to keep listening for any new chats starting from now so that if somebody types, we will recieve it, so this is the starting from now date which will return to the current date and time (Date())
        
        // What we want to do is add one second to this date, and the reason that we are doing this is because when we do a filter in firebase is greater than specific date, for some reason, if there is another object with the value of the same date, so it will return that one as well, so we don't want to do it, for example in our case if I put it if I don't add the current date, this last message will be returned twice, so if I add one second to the last message date, it will keep this message
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate  // this will be our function that returns the last message date
    }
    
    
    //MARK: - Gallery
    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Audio Messages
    @objc func recordAudio() {
        // dümdüz kullandığımızda üzerine basılı tuttuğumuz süre içerisinde bir çok kez çağırıyor ve isteiğimiz 1 kez algıladıktan sonra ses tekrar tekrar fonksiyonu kullanmaması
        switch longPressGesture.state { // the state is going to have a case that began
        case .began:
            
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
            
        case.ended:
            
            AudioRecorder.shared.finishRecording()
            
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
                
            } else {
                print("Ses dosyası yok.")
            }
            
            audioFileName = ""
            
        @unknown default: // we have other cases but we are not really interested in them and I'm going to put here unknown
            print("Bilinmeyen")
        }
        
    }
    
}


extension ChatViewController: GalleryControllerDelegate {
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
