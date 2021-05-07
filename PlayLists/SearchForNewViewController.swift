//
//  SearchForNewViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-17.
//

import UIKit

class GenreCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
}

class PlatformCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
}

class SearchForNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let GENRES_LIST_URL = "https://api.igdb.com/v4/genres";
    let PLATFORMS_LIST_URL = "https://api.igdb.com/v4/platforms";
    
    let genreCellIdentifier = "GenreCell";
    let platformCellIdentifier = "PlatformCell";
    
    let searchResultsSegueID = "SearchResults";
    
    @IBOutlet weak var genreTableView: UITableView!
    @IBOutlet weak var platformTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    var searchDataActivityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200));
    
    var genreList = [GenreData]();
    var platformList = [PlatformData]();
    
    var selectedGenres = [GenreData]();
    var selectedPlatforms = [PlatformData]();
    
    var dataQueue = DispatchQueue(label: "getSearchParams");
    var dataGroup = DispatchGroup();

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = IGDBAPI();
        searchButton.isEnabled = false;
        searchDataActivityIndicator.center = self.view.center;
        searchDataActivityIndicator.style = .large;
        displayActivityIndicator();
        dataGroup.enter();
        dataGroup.enter();
        dataQueue.async {
            IGDBAPI.igdbAPI.getGenreList(handleCompletion: self.setGenreList(_:))
            IGDBAPI.igdbAPI.getPlatformList(handleCompletion: self.setPlatformList(_:));
        }
        dataGroup.notify(queue: dataQueue, execute: {
            DispatchQueue.main.async {
                self.hideActivityIndicator();
            }
        })
    }
    
    func setGenreList(_ genreList: [GenreData]) {
        self.genreList = genreList;
        self.dataGroup.leave();
        DispatchQueue.main.async {
            self.genreTableView.reloadData();
        }
    }
    
    func setPlatformList(_ platformList: [PlatformData]) {
        self.platformList = platformList;
        self.dataGroup.leave();
        DispatchQueue.main.async {
            self.platformTableView.reloadData();
        }
    }
    
    // MARK: Activity Indicator
    
    func displayActivityIndicator() {
        self.view.addSubview(searchDataActivityIndicator);
        searchDataActivityIndicator.startAnimating();
    }
    
    func hideActivityIndicator() {
        searchDataActivityIndicator.removeFromSuperview();
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int;
        if (tableView == genreTableView) {
            count = genreList.count;
        } else {
            count = platformList.count;
        }
        return count;
    }

    // Remove platform/genre from its respective list
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (tableView == genreTableView) {
            let selectedGenreRow = genreList[indexPath.row];
            if let index = selectedGenres.firstIndex(where: { $0.getId() == selectedGenreRow.getId() } ) {
                selectedGenres.remove(at: index);
            }
        } else {
            let selectedPlatformRow = platformList[indexPath.row];
            if let index = selectedPlatforms.firstIndex(where: { $0.getId() == selectedPlatformRow.getId() } ) {
                selectedPlatforms.remove(at: index);
            }
        }
        if (selectedGenres.count == 0 && selectedPlatforms.count == 0) {
            searchButton.isEnabled = false;
        }
    }
    
    // Add platform/genre to its respective list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == genreTableView) {
            let selectedGenreRow = genreList[indexPath.row];
            selectedGenres.append(selectedGenreRow);
        } else {
            let selectedPlatformRow = platformList[indexPath.row];
            selectedPlatforms.append(selectedPlatformRow);
        }
        searchButton.isEnabled = true;
    }
    
    // Handles cell display for both the list of Genres and the list of Platforms
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == genreTableView) {
            let cellIdentifier = genreCellIdentifier;
            let tableData = genreList;
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GenreCell;
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? GenreCell;
            }
            cell!.cellTitle?.text = tableData[indexPath.row].getName();
            return cell!;
        } else {
            let cellIdentifier = platformCellIdentifier;
            let tableData = platformList;
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PlatformCell;
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? PlatformCell;
            }
            cell!.cellTitle?.text = tableData[indexPath.row].getName();
            return cell!;
        }
    }
    
    @IBAction func submitSearch(_ sender: Any) {
        performSegue(withIdentifier: searchResultsSegueID, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == searchResultsSegueID) {
            let displayVC = segue.destination as! SearchResultsViewController;
            displayVC.initWithSearchQuery(searchGenres: self.selectedGenres, searchPlatforms: self.selectedPlatforms);
        }
    }

}
