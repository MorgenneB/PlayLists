//
//  Game.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import Foundation

// Intended for storing Games locally on the user's device
class Game: Codable {
    // Data retrieved from API
    private var gameData: GameData;
    
    // User-generated data
    private var rating: Int?;
    private var hoursPlayed: Int?;
    
    init(gameData: GameData) {
        self.gameData = gameData;
    }
    
    func getId() -> Int {
        return self.gameData.id!;
    }
    
    func getName() -> String {
        return self.gameData.name!;
    }
    
    func getPrimaryArtwork() -> Int? {
        if self.gameData.artworks != nil && self.gameData.artworks!.count > 1 {
            return self.gameData.artworks![0];
        } else {
            return nil;
        }
    }
    
    func getReleaseDate() -> Int? {
        return self.gameData.first_release_date;
    }
    
    func getFormattedReleaseDate() -> String {
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .medium;
        dateFormatter.timeStyle = .none;
        dateFormatter.locale = Locale(identifier: "en-CA");
        let releaseDate = Date(timeIntervalSince1970: TimeInterval(self.gameData.first_release_date!))
        let formattedReleaseDate = dateFormatter.string(from: releaseDate);
        return formattedReleaseDate;
    }
    
    func getSummary() -> String? {
        return self.gameData.summary;
    }
    
    func getPlatforms() -> [Int]? {
        return self.gameData.platforms;
    }
    
    func getGenres() -> [Int]? {
        return self.gameData.genres;
    }
    
    func getRating() -> Int? {
        return self.rating;
    }
    
    func setRating(rating: Int) {
        self.rating = rating;
    }
    
    func getHoursPlayed() -> Int? {
        return self.hoursPlayed;
    }
    
    func setHoursPlayed(hoursPlayed: Int) {
        self.hoursPlayed = hoursPlayed;
    }
}
