//
//  TriviaViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class TriviaViewController: UIViewController {
    let MIN_GAMES_REQUIRED = 10;
    let playTriviaSegueID = "PlayTrivia";
    var playlistGamesCount = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func startTrivia(_ sender: Any) {
        playlistGamesCount = GameDictionary.sharedPlaylists.getAllGames().count;
        if (playlistGamesCount < MIN_GAMES_REQUIRED) {
            displayNotEnoughGamesAlert()
        } else {
            performSegue(withIdentifier: playTriviaSegueID, sender: nil);
        }
    }
    
    // User must have a sufficient number of games in their collection for question generation
    func displayNotEnoughGamesAlert() {
        let alert = UIAlertController(title: "Not Enough Games", message: "Please ensure you have at least \(String(MIN_GAMES_REQUIRED)) games across your playlists before starting.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));

        self.present(alert, animated: true)
    }

    // Empty unwind function to allow other Trivia views to return here
    @IBAction func unwindToTriviaStart(sender: UIStoryboardSegue) {}
}
