//
//  ChannelTableViewController.swift
//  N-ber
//
//  Created by Seyma on 9.09.2023.
//

import UIKit

protocol ChannelDetailTableViewControllerDelegate {
    func didClickFollow()
}

class ChannelDetailTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutText: UITextView!
    
    
    //MARK: - Vars
    var channel: Channel!
    var delegate: ChannelDetailTableViewControllerDelegate?
    
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()  // tablonun ilk hücresi büyük  bir boşluğa sahip engellemek için bu kodu yazıyoruz
        
        showChannelData()
        configureRightBarButton()
    }

    
    
    //MARK: - Configure
    private func showChannelData() {
        self.title = channel.name
        nameLabel.text = channel.name
        membersLabel.text = "\(channel.memberIds.count) Üye"
        aboutText.text = channel.aboutChannel
        setAvatar(avatarLink: channel.avatarLink)
    }
    
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Takip Et", style: .plain, target: self, action: #selector(followChannel))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.systemOrange
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "MeAvatar")
                }
            }
        } else {
            self.avatarImageView.image = UIImage(named: "MeAvatar")
        }
    }
    
    
    
    //MARK: - Actions
    @objc func followChannel() {
        channel.memberIds.append(User.currentId)
        FirebaseChannelListener.shared.saveChannel(channel)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
