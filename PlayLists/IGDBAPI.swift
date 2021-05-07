//
//  IGDBAPI.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-17.
//

import Foundation
import UIKit

// Handles all requests to the IGDB API
// Retrieves various game-related data
class IGDBAPI {
    static let igdbAPI = IGDBAPI();
    private var dataStore = NSData();
    let GAME_LIST_URL = "https://api.igdb.com/v4/games";
    let GENRE_LIST_URL = "https://api.igdb.com/v4/genres";
    let PLATFORM_LIST_URL = "https://api.igdb.com/v4/platforms";
    let COVERS_LIST_URL = "https://api.igdb.com/v4/covers";
    let GET_GAME_FIELDS = "fields name, summary, age_ratings, artworks, platforms, genres, first_release_date, franchise, multiplayer_modes";
    private var genreList: [GenreData]?;
    private var platformList: [PlatformData]?;
    
    // Retrieves full list of genres
    // Stores the list so it does not need to be reloaded during the current session
    func getGenreList(handleCompletion: @escaping (([GenreData]) -> Void)) {
        if (self.genreList == nil) {
            let url: NSURL = NSURL(string: self.GENRE_LIST_URL)!;
            var request = self.prepareRequest(url: url);
            request.httpBody = "fields name; sort name asc; limit 500;".data(using: .utf8, allowLossyConversion: false);
            let config = URLSessionConfiguration.default;
            let session = URLSession(configuration: config);
            let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
                self.dataStore = data! as NSData;
                self.genreList = self.parseJSONResponse(GenreData.self);
                DispatchQueue.main.async {
                    handleCompletion(self.genreList!);
                }
            })
            task.resume();
        } else {
            handleCompletion(self.genreList!);
        }
    }
    
    // Retrieves full list of platforms
    // Stores the list so it does not need to be reloaded during the current session
    func getPlatformList(handleCompletion: @escaping (([PlatformData]) -> Void)) {
        if (self.platformList == nil) {
            let url: NSURL = NSURL(string: self.PLATFORM_LIST_URL)!;
            var request = self.prepareRequest(url: url);
            request.httpBody = "fields name; sort name asc; limit 500;".data(using: .utf8, allowLossyConversion: false);
            let config = URLSessionConfiguration.default;
            let session = URLSession(configuration: config);
            let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
                self.dataStore = data! as NSData;
                self.platformList = self.parseJSONResponse(PlatformData.self);
                DispatchQueue.main.async {
                    handleCompletion(self.platformList!);
                }
            })
            task.resume();
        } else {
            handleCompletion(self.platformList!);
        }
    }
    
    // Searches the list and returns games with names matching some search term
    func searchByName(searchTerm: String, handleCompletion: @escaping (([Game]) -> Void)) {
        let url: NSURL = NSURL(string: self.GAME_LIST_URL)!;
        var request = self.prepareRequest(url: url);
        request.httpBody = generateSearchByTerm(searchTerm: searchTerm);
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
            self.dataStore = data! as NSData;
            let searchResults = self.parseJSONResponse(GameData.self);
            var gameResults = [Game]();
            for result in searchResults {
                gameResults.append(Game(gameData: result));
            }
            DispatchQueue.main.async {
                handleCompletion(gameResults);
            }
        })
        task.resume();
    }
    
    // Returns the game's box art from the IGDB Covers API
    func getArtwork(gameId: Int, handleCompletion: @escaping ((UIImage?) -> Void)) {
        let url: NSURL = NSURL(string: self.COVERS_LIST_URL)!;
        var request = self.prepareRequest(url: url);
        request.httpBody = "fields width, height, url; where game = \(gameId);".data(using: .utf8, allowLossyConversion: false)!;
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
            self.dataStore = data! as NSData;

            let imageResponse = self.parseJSONResponse(ImageData.self);
            if imageResponse.count > 0 {
                // API returns a URL path that expects you to append "http(s):" to the beginning
                let urlPath = "https:\(imageResponse[0].getUrl())";
                let url = NSURL(string: urlPath)
                let imageData = NSData(contentsOf: url! as URL);
                let image = UIImage(data: imageData! as Data)!;
                DispatchQueue.main.async {
                    handleCompletion(image);
                }
            } else {
                DispatchQueue.main.async {
                    handleCompletion(nil);
                }
            }
        })
        task.resume();
    }
    
    // Creates a search request based on genres and platforms the user is interested in playing games for
    func searchByGenreAndPlatform(searchForGenres genres: [GenreData], searchForPlatforms platforms: [PlatformData], handleCompletion: @escaping (([Game]) -> Void)) {
        let url: NSURL = NSURL(string: self.GAME_LIST_URL)!;
        var request = self.prepareRequest(url: url);
        request.httpBody = generateSearchQuery(searchForGenres: genres, searchForPlatforms: platforms);
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let task = session.dataTask(with: request, completionHandler:{ (data, response, error) in
            self.dataStore = data! as NSData;
            let searchResults = self.parseJSONResponse(GameData.self);
            var gameResults = [Game]();
            for result in searchResults {
                gameResults.append(Game(gameData: result));
            }
            DispatchQueue.main.async {
                handleCompletion(gameResults);
            }
        })
        task.resume();
    }
    
    // Creates a search clause for a given search term to use in the IGDB API request
    private func generateSearchByTerm(searchTerm: String) -> Data {
        var searchQuery = "\(GET_GAME_FIELDS); limit 500; ";
        searchQuery += "search \"\(searchTerm)\";"
        return searchQuery.data(using: .utf8, allowLossyConversion: false)!;
    }
    
    // Parses the list of genres and platforms and generates a "where" clause for the IGDB API request
    // This where clause contains every genre and platform requested by the user
    private func generateSearchQuery(searchForGenres genres: [GenreData], searchForPlatforms platforms: [PlatformData]) -> Data {
        var searchQuery = "\(GET_GAME_FIELDS); sort name asc; limit 500; where ";
        // Append genres if they were included
        if (genres.count > 0) {
            searchQuery += "genres = {\(genres[0].getId())";
            for genre in genres[1..<genres.endIndex] {
                searchQuery += ", \(genre.getId())";
            }
            searchQuery += "}";
        }
        // Append platforms if they were included
        if (platforms.count > 0) {
            // Ensure query handles both genres and platforms
            if (genres.count > 0) {
                searchQuery += " & ";
            }
            searchQuery += "platforms = {\(platforms[0].getId())";
            for platform in platforms[1..<platforms.endIndex] {
                searchQuery += ", \(platform.getId())";
            }
            searchQuery += "}";
            
        }
        searchQuery += ";";
        return searchQuery.data(using: .utf8, allowLossyConversion: false)!;
    }

    // Function that parses JSON response and returns an array of objects, given generic type T
    private func parseJSONResponse<T>(_ type: T.Type) -> [T] where T : Decodable {
        var jsonResult = [T]();
        do {
            jsonResult = try JSONDecoder().decode([T].self, from: self.dataStore as Data);
        } catch {
            print("Something went wrong!");
            print("Received data:")
            print(dataStore)
            print("received error:")
            print(error);
        }
        return jsonResult;
    }
    
    // Sets request headers as required by the IGDB API
    private func prepareRequest(url: NSURL) -> URLRequest {
        _ = IGDBToken();
        var request = URLRequest.init(url: url as URL);
        request.httpMethod = "POST";
        request.setValue(IGDBToken.igdbToken.getClientId(), forHTTPHeaderField: "Client-ID");
        request.setValue("Bearer \(IGDBToken.igdbToken.getAccessToken())", forHTTPHeaderField: "Authorization");
        request.setValue("application/json", forHTTPHeaderField: "Accept");
        return request;
    }
    
}
