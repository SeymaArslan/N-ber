//
//  SettingsTableViewController.swift
//  N-ber
//
//  Created by Seyma on 19.08.2023.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    //MARK: - Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView() // boş hücrelerin görünümünü engelliyor gerçi yeni sürümde eski sürümdeki gibi boş satırlar görünmüyor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView() // sectionları sil
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // section boyut
        return section == 0 ? 0.0 : 5.0  // section == 0 ilk section eğer ilk sectionsa 0 değilse 10
    }
    
    //MARK: -  Actions
    @IBAction func tellAFrindButtonPressed(_ sender: Any) {
        print("Arkadaşlarına öner")
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
        print("Şartlar ve Koşullar")
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        print("Çıkış")
    }
    
    
    //MARK: - Update UI
    private func showUserInfo(){
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            appVersionLabel.text = "Uygulama Versiyon \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != "" {
                // download and set avatar image
            }
            
        }
    }
    
}
