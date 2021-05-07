//
//  PlaylistsViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class PlaylistCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!;
}

class PlaylistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var tableData = [Playlist]();
    let cellIdentifier = "PlaylistCell";
    let displayPlaylistSegueID = "PlaylistDetailView";

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = GameDictionary();
        GameDictionary.sharedPlaylists.loadPlaylists();

        tableData = GameDictionary.sharedPlaylists.getPlaylists();
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: displayPlaylistSegueID, sender: tableData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PlaylistCell;
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? PlaylistCell;
        }
        cell?.cellTitle?.text = tableData[indexPath.row].getName();
        return cell!;
    }
    
    // Deletes a playlist
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            self.tableData.remove(at: indexPath.row);
            // Delete playlist
            GameDictionary.sharedPlaylists.removePlaylist(at: indexPath.row)
            // Update table view
            self.tableView.deleteRows(at: [indexPath], with: .fade);
            self.tableView.reloadData();
            completionHandler(true);
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction]);
        return swipeConfiguration;
    }

    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == displayPlaylistSegueID) {
            let displayVC = segue.destination as! PlaylistDetailViewController;
            displayVC.initWithPlaylist(playlist: sender as! Playlist);
        }
    }
    
    @IBAction func addNewPlaylist() {
        let alert = UIAlertController(title: "Enter the new playlist's name:", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil);

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let playlistName = alert.textFields?.first?.text {
                GameDictionary.sharedPlaylists.addPlaylist(name: playlistName);
                self.tableData = GameDictionary.sharedPlaylists.getPlaylists();
                self.tableView.reloadData();
            }
        }))

        self.present(alert, animated: true)
    }

}
