//
//  ImageData.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-18.
//

import Foundation

// Stores data from IGDB covers API
class ImageData: Codable {
    private var width: Int;
    private var height: Int;
    private var url: String;
    
    init(width: Int, height: Int, url: String) {
        self.width = width;
        self.height = height;
        self.url = url;
    }
    
    func getUrl() -> String {
        return self.url;
    }
}
