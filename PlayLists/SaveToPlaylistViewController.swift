//
//  SaveToPlaylistViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class SaveToPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableData = [Playlist]();
    var playlistIndex: Int?;
    let gameSaveSegueID = "UnwindOnGameSave"
    let cellIdentifier = "SelectPlaylistCell";

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = GameDictionary();
        tableData = GameDictionary.sharedPlaylists.getPlaylists();
        // Do any additional setup after loading the view.
    }
    
    func getPlaylistIndex() -> Int? {
        return self.playlistIndex;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playlistIndex = indexPath.row;
        performSegue(withIdentifier: gameSaveSegueID, sender: nil);
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PlaylistCell;
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? PlaylistCell;
        }
        cell?.cellTitle?.text = tableData[indexPath.row].getName();
        return cell!;
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }

}
