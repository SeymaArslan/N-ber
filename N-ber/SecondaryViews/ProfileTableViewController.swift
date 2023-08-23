//
//  ProfileTableViewController.swift
//  N-ber
//
//  Created by Seyma on 23.08.2023.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //MARK: - Vars
    var user: User?
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        setupUI()
    }
    
    //MARK: - Tableview Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            print("Sohbet başladı")
            //TODO: sohbet sayfası
        }
    }

    //MARK: - SetupUI
    private func setupUI() {
        if user != nil {
            self.title = user!.username
            usernameLabel.text = user?.username
            statusLabel.text = user?.status
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
            
        }
    }
    
}