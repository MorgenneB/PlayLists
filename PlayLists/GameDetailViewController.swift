//
//  GameDetailViewController.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import UIKit

class GameDetailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var gameArtwork: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var platformText: UITextView!
    @IBOutlet weak var summaryText: UITextView!
    @IBOutlet weak var genreText: UITextView!
    @IBOutlet weak var saveToPlaylistButton: UIBarButtonItem!
    @IBOutlet weak var userRatingAndHours: UIStackView!
    @IBOutlet weak var userRatingField: UITextField!
    @IBOutlet weak var hoursPlayedField: UITextField!
    @IBOutlet weak var gameDetailView: UIScrollView!
    
    
    // Constrain user rating from 0-10
    var MAX_RATING = 10;
    // Constrain max hours played: theoreticallly possibly but very unlikely
    var MAX_HOURS_PLAYED = 100000;
    
    var genreList = [GenreData]();
    var platformList = [PlatformData]();
    
    let initializingDataView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200));
    
    var gameInPlaylist = false;
    
    var game: Game?;
    let saveToPlaylistSegueID = "SaveToPlaylist";
    var dataGroup = DispatchGroup();
    var dataQueue = DispatchQueue(label: "getGameData");
    var imageQueue = DispatchQueue(label: "gameArtwork");

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = GameDictionary();
        // Hide user inputs until it's determined the game is in a playlist
        userRatingAndHours.isHidden = true;
        // Hide detail view until data has loaded
        gameDetailView.isHidden = true;
        initializingDataView.center = self.view.center;
        initializingDataView.style = .large;
        displayActivityIndicator();
        // Setup DispatchGroup, wait for it to return necessary data
        dataGroup.enter();
        dataGroup.enter();
        dataQueue.async {
            IGDBAPI.igdbAPI.getGenreList(handleCompletion: self.setGenreList(_:))
            IGDBAPI.igdbAPI.getPlatformList(handleCompletion: self.setPlatformList(_:));
        }
        // Load image separately from the above data
        imageQueue.async {
            IGDBAPI.igdbAPI.getArtwork(gameId: self.game?.getId() ?? 0, handleCompletion: self.displayArtwork(_:))
        }
        dataGroup.notify(queue: dataQueue, execute: {
            DispatchQueue.main.async {
                self.displayGame();
                self.hideActivityIndicator();
            }
        })
        userRatingField.delegate = self;
        hoursPlayedField.delegate = self;
    }
    
    func initWithGame(game: Game) {
        self.game = game;
    }
    
    // MARK: Activity Indicator
    
    func displayActivityIndicator() {
        self.view.addSubview(initializingDataView);
        initializingDataView.startAnimating();
    }
    
    func hideActivityIndicator() {
        initializingDataView.removeFromSuperview();
    }
    
    // MARK: Update Detail View
    
    func displayGame() {
        // If user has saved the game to a playlist, allows them to enter a rating and hours played
        if (GameDictionary.sharedPlaylists.gameInPlaylist(game: game!)) {
            setUserInteraction();
        }
        self.navigationItem.title = self.game?.getName();
        displayReleaseDate();
        displayPlatforms();
        displayGenres()
        self.summaryText.text = self.game?.getSummary() ?? "N/A";
        self.userRatingField.text = String(self.game?.getRating() ?? 0);
        self.hoursPlayedField.text = String(self.game?.getHoursPlayed() ?? 0);
        gameDetailView.isHidden = false;
    }
    
    func setUserInteraction() {
        setSaveIcon();
        userRatingAndHours.isHidden = false;
    }
    
    func displayArtwork(_ artwork: UIImage?) {
        if artwork != nil {
            gameArtwork.image = artwork;
        }
    }
    
    func displayPlatforms() {
        var platforms = "";
        if let gamePlatforms = game?.getPlatforms() {
            // Add first platform, then comma delimit any further platforms
            var platformData = platformList.first(where: { $0.getId() == gamePlatforms[0] });
            platforms += platformData!.getName();
            for i in 1..<gamePlatforms.count {
                platformData = platformList.first(where: { $0.getId() == gamePlatforms[i] });
                platforms += ", \(platformData!.getName())";
            }
        } else {
            platforms = "N/A";
        }
        platformText.text = platforms;
    }
    
    func displayGenres() {
        var genres = "";
        if let gameGenres = game?.getGenres() {
            // Add first genre, then comma delimit any further platforms
            var genreData = genreList.first(where: { $0.getId() == gameGenres[0] });
            genres += genreData!.getName();
            for i in 1..<gameGenres.count {
                genreData = genreList.first(where: { $0.getId() == gameGenres[i] });
                genres += ", \(genreData!.getName())";
            }
        } else {
            genres = "N/A";
        }
        genreText.text = genres;
    }
    
    func displayReleaseDate() {
        if let releaseDateInterval = game!.getReleaseDate() {
            let dateFormatter = DateFormatter();
            dateFormatter.dateStyle = .medium;
            dateFormatter.timeStyle = .none;
            dateFormatter.locale = Locale(identifier: "en-CA");
            let releaseDate = Date(timeIntervalSince1970: TimeInterval(releaseDateInterval))
            let formattedReleaseDate = dateFormatter.string(from: releaseDate);
            releaseDateLabel.text = formattedReleaseDate;
        } else {
            releaseDateLabel.text = "N/A";
        }

    }
    
    // Disable the save playlist button if the game is saved to a playlist
    func setSaveIcon() {
        saveToPlaylistButton.isEnabled = false;
        saveToPlaylistButton.image = UIImage(systemName: "checkmark")
    }
    
    func setGenreList(_ genreList: [GenreData]) {
        self.genreList = genreList;
        dataGroup.leave();
    }
    
    func setPlatformList(_ platformList: [PlatformData]) {
        self.platformList = platformList;
        dataGroup.leave();
    }
    
    // MARK: UIGestureRecognizer
    
    @IBAction func closeKeyboard(_ sender: UIGestureRecognizer) {
        userRatingField.resignFirstResponder();
        hoursPlayedField.resignFirstResponder();
    }
    
    // Ensures user input is valid; input must be an integer no greater than the predefined max values
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true;
        } else if Int(string) == nil {
            return false;
        }
        let newText = textField.text! + string;
        let newTextAsNumber = Int(newText);
        // Verify that the new character is a number and that it will not produce a number too large
        if (textField == userRatingField) {
            return newTextAsNumber! <= MAX_RATING;
        } else if (textField == hoursPlayedField) {
            return newTextAsNumber! <= MAX_HOURS_PLAYED;
        }
        return false;
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text != "") {
            if (textField == userRatingField) {
                game?.setRating(rating: Int(textField.text!)!);
            } else if (textField  == hoursPlayedField) {
                game?.setHoursPlayed(hoursPlayed: Int(textField.text!)!);
            }
        }
    }
    
    // MARK: Segues
    
    // Opens list of playlists for user to selects
    @IBAction func saveToPlaylist(_ sender: Any) {
        performSegue(withIdentifier: saveToPlaylistSegueID, sender: self.game)
    }
    
    @IBAction func unwindToGameDetail(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SaveToPlaylistViewController,
           let index = sourceViewController.getPlaylistIndex() {
            // Add game to requested playlist
            GameDictionary.sharedPlaylists.addGameToPlaylist(self.game!, at: index)
            setUserInteraction();
        }
    }

}
