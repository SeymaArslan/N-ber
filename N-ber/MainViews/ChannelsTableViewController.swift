//
//  ChannelsTableViewController.swift
//  N-ber
//
//  Created by Seyma on 7.09.2023.
//

import UIKit

class ChannelsTableViewController: UITableViewController {

    //MARK: - IB Outlets
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.largeTitleDisplayMode = .always
        self.title = "Kanallar"
        
        tableView.tableFooterView = UIView()  // there is empty cells when we dont anything in our tableView, I want to hide
     
    }

    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    
    //MARK: - IB Actions
    
    @IBAction func channelSegmentValueChanged(_ sender: Any) {
    }
    


}
