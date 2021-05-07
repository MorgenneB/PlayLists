//
//  IGDBToken.swift
//  PlayLists
//
//  Created by Morgenne Besenschek on 2021-04-15.
//

import Foundation

class IGDBToken {
    static let igdbToken = IGDBToken();
    private let URL_PATH = "https://id.twitch.tv/oauth2/token";
    private let CLIENT_ID = "REQUIRES_TWITCH_CLIENT_ID";
    private let CLIENT_SECRET = "REQUIRES_TWITCH_CLIENT_SECRET";
    private let GRANT_TYPE = "client_credentials";
    
    // Struct containing the exact format of an IGDB access token as returned in JSON
    private struct Token: Codable {
        var access_token: String?
        // Token should be refreshed on expiry but is not due to time constraints
        // However, the token lasts for ~60 days per the IGDB API documentation
        var expires_in: Date?
        var token_type: String?
    }
    
    private var token = Token();
    
    func getClientId () -> String {
        return self.CLIENT_ID;
    }
    
    func getAccessToken() -> String {
        if (self.token.access_token != nil) {
            return self.token.access_token!;
        } else {
            queryToken();
            return self.token.access_token ?? "";
        }
    }
    
    func loadToken() {
        if (self.token.access_token == nil) {
            queryToken();
        }
    }
    
    private func queryToken() {
        var dataStore = NSData();
        // Construct URL with required query parameters
        var queryItems = [URLQueryItem]();
        queryItems.append(URLQueryItem(name: "client_id", value: CLIENT_ID));
        queryItems.append(URLQueryItem(name: "client_secret", value: CLIENT_SECRET));
        queryItems.append(URLQueryItem(name: "grant_type", value: GRANT_TYPE));
        var urlConstruct = URLComponents(string: URL_PATH);
        urlConstruct?.queryItems = queryItems;
        let url = urlConstruct?.url;
        var request = URLRequest.init(url: url!);
        request.httpMethod = "POST";
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let tokenTask = session.dataTask(with: request, completionHandler:{ (data, response, error) in
            dataStore = data! as NSData;
            do {
                self.token = try JSONDecoder().decode(Token.self, from: dataStore as Data);
            } catch {
                print(error)
            }
        })
        tokenTask.resume();
    }
}
