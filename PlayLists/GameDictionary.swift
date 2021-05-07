//
//  GameDictionary.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import Foundation
import UIKit

// Handles static sharing of Playlists, and loads/saves the Playlists to phone storage
class GameDictionary {
    static let sharedPlaylists = GameDictionary();
    private var playlists: [Playlist]?;
    let fileName = "PlayLists-Data";
    var fileURL : URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectoryURL.appendingPathComponent(fileName)
    }
    
    func getPlaylists() -> [Playlist] {
        return self.playlists!;
    }
    
    // Returns all games stored across all playlists
    func getAllGames() -> [Game] {
        var games = [Game]();
        for playlist in self.playlists! {
            games.append(contentsOf: playlist.getGames());
        }
        return games;
    }
    
    // Function to determine if a game exists in any of the playlists
    func gameInPlaylist(game: Game) -> Bool {
        var gameInPlaylist = false;
        var games = [Game]();
        for playlist in self.playlists! {
            games.append(contentsOf: playlist.getGames());
        }
        var i = 0;
        while i < games.count && !gameInPlaylist {
            if games[i].getId() == game.getId() {
                gameInPlaylist = true;
            }
            i += 1;
        }
        return gameInPlaylist
    }
    
    // Adds a new playlist
    func addPlaylist(name: String) {
        playlists?.append(Playlist(name: name));
    }
    
    // Adds a new game to a specified playlist
    func addGameToPlaylist(_ game: Game, at index: Int) {
        playlists?[index].addGame(game: game);
    }
    
    // Initializes the default Playlists that should appear on first app boot
    func initializePlaylists() {
        playlists = [Playlist]();
        playlists?.append(Playlist(name: "To Play"));
        playlists?.append(Playlist(name: "In Progress"));
        playlists?.append(Playlist(name: "Completed"));
    }
    
    func removePlaylist(at index: Int) {
        if (playlists!.count > 0) {
            playlists?.remove(at: index);
        }
    }
    
    // Loads playlists from storage
    func loadPlaylists() {
        if (UserDefaults.standard.bool(forKey: "hasLaunchedBefore")) {
            let jsonDecoder = JSONDecoder();
            var playlistsData = Data();
            var loadedPlaylistsFromArchive = false;
            do {
                playlistsData = try Data(contentsOf: fileURL);
            } catch {}
            do{
                playlists = try jsonDecoder.decode([Playlist].self, from: playlistsData);
                loadedPlaylistsFromArchive = true;
            } catch {
                print("could not decode playlists")
                
            }
            if (!loadedPlaylistsFromArchive) {
                initializePlaylists();
            }
        } else {
            initializePlaylists();
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore");
        }
    }
    
    // Saves playlists to storage
    func savePlaylists(){
        let jsonEncoder = JSONEncoder();
        var playlistsData = Data();
        do {
            playlistsData = try jsonEncoder.encode(playlists);
            print(playlistsData)
        } catch {
            print("could not encode the playlists");
        }
        do {
            try playlistsData.write(to: fileURL, options: []);
        } catch { }
    }
    
}
