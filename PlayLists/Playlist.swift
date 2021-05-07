//
//  GameList.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import Foundation

// A playlist can be named and holds a list of games associated with it
class Playlist: Codable {
    private var name: String;
    private var games: [Game]?;
    
    init(name: String) {
        self.name = name;
        self.games = [Game]();
    }
    
    init(name: String, games: [Game]) {
        self.name = name;
        self.games = games;
    }
    
    func getName() -> String {
        return self.name;
    }
    
    func addGame(game: Game) {
        self.games!.append(game);
    }
    
    func getGames() -> [Game] {
        return self.games!;
    }
    
    func removeGame(at index: Int) {
        if (games!.count > 0) {
            self.games!.remove(at: index);
        }
    }
}
