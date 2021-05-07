//
//  SearchByNameViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class SearchByNameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, URLSessionTaskDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchDataActivityIndicator =  UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200));
    
    let gameDetailSegueID = "GameDetailView";
    let cellIdentifier = "SearchGameCell";
    
    let dataQueue = DispatchQueue(label: "searchByName");
    var dataStore = NSData();
    
    var tableData = [Game]();

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self;
        searchDataActivityIndicator.center = self.view.center;
        searchDataActivityIndicator.style = .large;
    }
    
    func displayResults(games: [Game]) {
        self.tableData = games;
        hideActivityIndicator();
        if (self.tableData.count > 0) {
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        } else {
            displayNoResultsAlert();
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clearTable()
        searchBar.resignFirstResponder();
        displayActivityIndicator();
        let searchText = self.searchBar.text;
        dataQueue.async {
            IGDBAPI.igdbAPI.searchByName(searchTerm: searchText!, handleCompletion: self.displayResults(games:))
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
        return tableData.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: gameDetailSegueID, sender: tableData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GameCell;
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier) as? GameCell;
        }
        cell?.cellTitle?.text = tableData[indexPath.row].getName();
        return cell!;
    }
    
    // Ensure table is empty before appending new search results
    func clearTable() {
        tableData = [Game]();
        self.tableView.reloadData();
    }
    
    // Inform user that no search results were found
    func displayNoResultsAlert() {
        let alert = UIAlertController(title: "No Results Found", message: "It looks like there weren't any results matching your query. Please try a different combination!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));

        self.present(alert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }

    // MARK: Segue
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == gameDetailSegueID) {
            let displayVC = segue.destination as! GameDetailViewController;
            displayVC.initWithGame(game: sender as! Game);
        }
    }

}
