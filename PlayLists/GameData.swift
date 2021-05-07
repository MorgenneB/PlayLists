//
//  GameData.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-16.
//

import Foundation

// Intended for holding a list details of a particular Game,
// as retrieved from the IGDB API
struct GameData: Codable {
    var name: String?;
    var id: Int?;
    var summary: String?;
    var involved_companies: [Int]?;
    var age_ratings: [Int]?;
    var artworks: [Int]?;
    var platforms: [Int]?;
    var genres: [Int]?;
    var first_release_date: Int?;
    var franchises: [Int]?
    var multiplayer_modes: [Int]?
}
