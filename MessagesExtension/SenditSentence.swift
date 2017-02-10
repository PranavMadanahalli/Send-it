//
//  SenditSentence.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/3/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import Foundation
import Messages



struct SenditSentence {
    // MARK: Properties
    
    var sentence: [String]
    var isComplete: Bool
    
    var second: String
    
    var rounds: String
    
    var currentPlayer: String
    
    var starterSent: String
}

extension SenditSentence{
    // MARK: Computed properties
    func encode() -> URL {
        let baseURL = "www.shinobicontrols.com/battleship"
        
        guard var components = URLComponents(string: baseURL) else {
            fatalError("Invalid base url")
        }
        
        var items = [URLQueryItem]()
        
        
        
        // sentence
        let sentenceItems = sentence.map {
            senditWord in
            URLQueryItem(name: "Ship_Location", value: String(describing: senditWord))
        }
        
        items.append(contentsOf: sentenceItems)
        
        
        // Game Complete
        let complete = isComplete ? "1" : "0"
        
        let completeItem = URLQueryItem(name: "Is_Complete", value: complete)
        
        items.append(completeItem)
        
        let player = currentPlayer
        
        let playerItem = URLQueryItem(name: "currentPlayer", value: player)
        
        items.append(playerItem)
        
        
        let sec  = second
        
        let secondItem = URLQueryItem(name: "second", value: sec)
        
        items.append(secondItem)
        
        
        let rod  = rounds
        
        let roundItem = URLQueryItem(name: "rounds", value: rod)
        
        items.append(roundItem)
        
        
        let starter  = starterSent
        
        let starterItem = URLQueryItem(name: "starter", value: starter)
        
        items.append(starterItem)
        
        
        
        components.queryItems = items
        
    
        
        guard let url = components.url else {
            fatalError("Invalid URL components")

        }
        return url
    }

}


extension SenditSentence {
    init?(from url: URL) {
        // Parse the url
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let componentItems = components.queryItems else {
                fatalError("Invalid message url")
        }
        
        // Naïvely retrieve the battleship cell location from the URL
        sentence = componentItems.filter({ $0.name == "Ship_Location" }).map({ String($0.value!)! })
        
        // Even more naïvely retrieve game completion stat
        let completeQueryItem = componentItems.filter({ $0.name == "Is_Complete" }).first!
        isComplete = completeQueryItem.value! == "1"
        
        let playerQueryItem = componentItems.filter({ $0.name == "currentPlayer" }).first!
        currentPlayer = playerQueryItem.value!
        
        let secondQueryItem = componentItems.filter({ $0.name == "second" }).first!
        second = secondQueryItem.value!
        
        
        let roundQueryItem = componentItems.filter({ $0.name == "rounds" }).first!
        rounds = roundQueryItem.value!
        
        let sentQueryItem = componentItems.filter({ $0.name == "starter" }).first!
        starterSent =  sentQueryItem.value!
        
    }
    
}
extension SenditSentence {
    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        self.init(from: messageURL)
    }
}



