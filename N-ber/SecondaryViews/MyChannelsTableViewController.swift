//
//  MyChannelsTableViewController.swift
//  N-ber
//
//  Created by Seyma on 7.09.2023.
//

import UIKit

class MyChannelsTableViewController: UITableViewController {

    //MARK: - Vars
    var myChannels: [Channel] = [] // is going to hold all the channels
    
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView() // and this will get read of empty cells
        downloadUserChannels()
    }
    
    
    
    //MARK: - Download Channels
    private func downloadUserChannels() {
        FirebaseChannelListener.shared.downloadUserChannelsFromFirebase { allChannels in
            
            self.myChannels = allChannels
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    //MARK: - IBActions
    @IBAction func addBarButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "myChannelToAddSeg", sender: self)
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        
        return myChannels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell

        cell.configure(channel: myChannels[indexPath.row]) // provide it to our celli which in turn is going to set our user interface
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "myChannelToAddSeg", sender: myChannels[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {  // So this allows our user to edit each cell because we are the admins and we are allowed to delete this channels
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {  // swipe delete
        // and here we want to check if the user wants to delete, so we say if editing style is equals to delete
        
        if editingStyle == .delete {
//            print("indexin hücresi silindi ", indexPath)
            
            let channelToDelete = myChannels[indexPath.row]
            
            myChannels.remove(at: indexPath.row)  // and also, we just don't want to only delete it in firebase, but we also want to remove it from the array so that we no longer have it in our source.
            
            FirebaseChannelListener.shared.deleteChannel(channelToDelete)
            
            tableView.deleteRows(at: [indexPath], with: .automatic) // .SO first we access temporary channel and then we remove it from our array and we will remove it from our firebase
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "myChannelToAddSeg" {
            
            let editChannelView = segue.destination as! AddChannelTableViewController
            
            editChannelView.channelToEdit = sender as? Channel
        }
        
    }
    
}
