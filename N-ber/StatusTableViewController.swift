//
//  StatusTableViewController.swift
//  N-ber
//
//  Created by Seyma on 21.08.2023.
//

import UIKit

class StatusTableViewController: UITableViewController {

    //MARK: - Vars
    var allStatus: [String] = []
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView() // boş hücrelerden kurtulduk
        loadUserStatus()
    }

    //MARK: - Table View data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStatus.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let status = allStatus[indexPath.row]
        cell.textLabel?.text = status
        cell.accessoryType = User.currentUser?.status == status ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - loading
    private func loadUserStatus() {
        allStatus = userDefaults.object(forKey: kStatus) as! [String]
        tableView.reloadData()
    }
}
