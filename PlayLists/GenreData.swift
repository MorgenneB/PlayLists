//
//  GenreData.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-17.
//

import Foundation

// Stores data from IGDB genres API
class GenreData: Codable {
    private var name: String;
    private var id: Int;
    
    init(name: String, id: Int) {
        self.name = name;
        self.id = id;
    }
    
    func getName() -> String {
        return self.name;
    }
    
    func getId() -> Int {
        return self.id;
    }
}
