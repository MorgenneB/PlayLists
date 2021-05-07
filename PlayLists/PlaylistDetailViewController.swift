//
//  PlaylistDetailViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import Foundation
import UIKit

class GameCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!;
    @IBOutlet weak var cellImage: UIImageView!;
}

class PlaylistDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var playlistTableView: UITableView!
    @IBOutlet weak var gameSearchBar: UISearchBar!
    
    let cellIdentifier = "GameCell";
    let displayGameFromPlaylistSegueId = "DisplayGameFromPlaylist";
    var playlist: Playlist?;
    private var tableData = [Game]();
    private var filteredData = [Game]();

    override func viewDidLoad() {
        super.viewDidLoad();
        displayPlaylist();
        gameSearchBar.delegate = self;
    }
    
    func initWithPlaylist(playlist: Playlist) {
        self.playlist = playlist;
    }
    
    func displayPlaylist() {
        self.navigationItem.title = self.playlist?.getName();
        tableData = self.playlist!.getGames();
        filteredData = tableData
    }
    
    // MARK: UISearchBarDelegate
    
    // Filters and sorts the playlist games based on search query (name) and selected filter option
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = tableData.filter({ game -> Bool in
            // Search by name
            if searchText.isEmpty {
                return true;
            }
            return game.getName().lowercased().contains(searchText.lowercased());
        });
        filteredData = filteredData.sorted(by: { gameOne, gameTwo in
            switch searchBar.selectedScopeButtonIndex {
                // Sort by name
                case 0:
                    return gameOne.getName().lowercased() < gameTwo.getName().lowercased()
                // Sort by rating
                case 1:
                    return gameOne.getRating() ?? -1 > gameTwo.getRating() ?? -1
                // Sort by hours played
                case 2:
                    return gameOne.getHoursPlayed() ?? -1 > gameTwo.getHoursPlayed() ?? -1
                default:
                    return false;
            }
        });
        playlistTableView.reloadData();
    }
    
    // Sorts the playlist of games based on the selected scope
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filteredData = filteredData.sorted(by: { gameOne, gameTwo in
            switch searchBar.selectedScopeButtonIndex {
                // Sort by name
                case 0:
                    return gameOne.getName().lowercased() < gameTwo.getName().lowercased()
                // Sort by rating
                case 1:
                    return gameOne.getRating() ?? -1 > gameTwo.getRating() ?? -1
                // Sort by hours played
                case 2:
                    return gameOne.getHoursPlayed() ?? -1 > gameTwo.getHoursPlayed() ?? -1
                default:
                    return false;
            }
        });
        playlistTableView.reloadData();
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        gameSearchBar.resignFirstResponder();
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: displayGameFromPlaylistSegueId, sender: filteredData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GameCell;
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? GameCell;
        }
        cell?.cellTitle?.text = filteredData[indexPath.row].getName();
        return cell!;
    }
    
    // Deletes a game from a playlist
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, sourceView, completionHandler) in
            // Delete from both sets of table data
            let removedGameIndex = self.tableData.firstIndex(where: {$0 === self.filteredData[indexPath.row]})
            self.tableData.remove(at: removedGameIndex!);
            self.filteredData.remove(at: indexPath.row);
            // Delete from playlist
            self.playlist?.removeGame(at: removedGameIndex!)
            // Update table view
            self.playlistTableView.deleteRows(at: [indexPath], with: .fade);
            self.playlistTableView.reloadData();
            completionHandler(true);
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction]);
        return swipeConfiguration;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == displayGameFromPlaylistSegueId) {
            let displayVC = segue.destination as! GameDetailViewController;
            displayVC.initWithGame(game: sender as! Game);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }

}
