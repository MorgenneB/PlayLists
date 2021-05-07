//
//  SearchGamesViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class SearchGamesViewController: UIViewController {
    let searchByNameSegueID = "SearchByName"
    let searchForNewGameSegueID = "SearchForNew";
    
    @IBOutlet weak var searchByNameButton: UIButton!
    @IBOutlet weak var searchForNewButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Credit to https://stackoverflow.com/questions/38318933/how-to-add-black-outline-to-uibutton-that-is-1px-wide
        searchByNameButton.layer.borderWidth = 5;
        searchByNameButton.layer.borderColor = UIColor.black.cgColor;
        searchForNewButton.layer.borderWidth = 5;
        searchForNewButton.layer.borderColor = UIColor.black.cgColor;
    }
    
    
    @IBAction func searchByName(_ sender: Any) {
        performSegue(withIdentifier: searchByNameSegueID, sender: nil)
    }
    
    @IBAction func searchForNew(_ sender: Any) {
        performSegue(withIdentifier: searchForNewGameSegueID, sender: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
