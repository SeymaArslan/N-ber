//
//  SettingsTableViewController.swift
//  N-ber
//
//  Created by Seyma on 19.08.2023.
//

import UIKit
import ProgressHUD

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "settingsToEditProfileSegue", sender: self)
        }
    }
    
    //MARK: -  Actions
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {

        let firstActivityItem = "N-ber'i paylaş"
        let secondActivityItem: NSURL = NSURL(string: "https://www.google.com")!
        let image: UIImage = UIImage(named: "icon.png")!
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.activityItemsConfiguration = [UIActivity.ActivityType.message] as? UIActivityItemsConfigurationReading
        
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Şartlar ve koşullar", message: "Linke gidiniz, Link: https://lionelo.tech/birEsnaf/index.php", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
               //     self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func deleteUserAccount(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Hesabınızı Silmek Üzeresiniz", message: "Devam etmek için Tamam'a tıklayın.", preferredStyle: .alert)
        let cancelAct = UIAlertAction(title: "İptal", style: .cancel)
        alertController.addAction(cancelAct)
        let okAct = UIAlertAction(title: "Tamam", style: .destructive) { action in
            FirebaseUserListener.shared.deleteAccountCurrentUser { error in
                if error == nil {
                    ProgressHUD.showSuccess("Hesabınız Silindi.")
                    let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                    DispatchQueue.main.async {
                        loginView.modalPresentationStyle = .fullScreen
                        self.present(loginView, animated: true, completion: nil)
                    }
                }
            }
            if var user = User.currentUser {
                FirebaseUserListener.shared.deleteUserToFirestore(user) { success in
                    if success {
                        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                        DispatchQueue.main.async {
                            loginView.modalPresentationStyle = .fullScreen
                            self.present(loginView, animated: true, completion: nil)
                        }
                    } else {
                        ProgressHUD.showSuccess("Silme işlemi gerçekleşemedi.")
                    }
                    
                }
            }
        }
        alertController.addAction(okAct)
        self.present(alertController, animated: true)
        
    }
    
    
    //MARK: - Update UI
    private func showUserInfo(){
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            appVersionLabel.text = "Uygulama Versiyon \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != "" {
                // download and set avatar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
            
        }
    }

}
