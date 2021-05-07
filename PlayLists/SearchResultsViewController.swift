//
//  SearchResultsViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-17.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var searchDataActivityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200));
    
    var searchGenres: [GenreData]?;
    var searchPlatforms: [PlatformData]?;
    
    var searchResults = [Game]();
    
    let cellIdentifier = "SearchGameCell";
    let gameDetailSegueID = "ShowGameDetail";
    
    let searchQueue = DispatchQueue(label: "searchByGenresPlatforms");

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = IGDBAPI();
        searchDataActivityIndicator.center = self.view.center;
        searchDataActivityIndicator.style = .large;
        displayActivityIndicator();
        searchQueue.async {
            IGDBAPI.igdbAPI.searchByGenreAndPlatform(searchForGenres: self.searchGenres!, searchForPlatforms: self.searchPlatforms!, handleCompletion: self.displaySearchResults(games:))
        }
    }
    
    func initWithSearchQuery(searchGenres: [GenreData], searchPlatforms: [PlatformData]) {
        self.searchGenres = searchGenres;
        self.searchPlatforms = searchPlatforms;
    }
    
    func displaySearchResults(games: [Game]) {
        self.searchResults = games;
        hideActivityIndicator();
        DispatchQueue.main.async {
            if (self.searchResults.count > 1) {
                self.searchResultsTableView.reloadData();
            } else {
                self.displayNoResultsAlert();
            }
        }
    }
    
    func displayNoResultsAlert() {
        let alert = UIAlertController(title: "No Results Found", message: "It looks like there weren't any results matching your query. Please try a different combination!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));

        self.present(alert, animated: true)
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
        return searchResults.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: gameDetailSegueID, sender: searchResults[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GameCell;
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? GameCell;
        }
        cell?.cellTitle?.text = searchResults[indexPath.row].getName();
        return cell!;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == gameDetailSegueID) {
            let displayVC = segue.destination as! GameDetailViewController;
            displayVC.initWithGame(game: sender as! Game);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }

}
