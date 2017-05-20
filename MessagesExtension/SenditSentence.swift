//
//  SenditSentence.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/3/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import Foundation
import Messages


//SenditSentence Model which has below attributes
//SenditSentence is the Game's model
struct SenditSentence {
    // MARK: Properties
    
    //string of words that make up the send it sentence
    var sentence: [String]
    
    var isComplete: Bool
    
    var second: String
    var rounds: String
    
    var currentPlayer: String
    
    var starterSent: String
}

//extension of SenditSentence that encodes the SenditSentence URL
extension SenditSentence{
    
    func encode() -> URL {
        //baseURL which i will query from. this url does not matter
        let baseURL = "www.sendit.send/it"
        
        guard var components = URLComponents(string: baseURL) else {
            fatalError("Invalid base url")
        }
        
        //array of items that were sucessfully queried
        var items = [URLQueryItem]()
        
        
        
        //send it sentence
        let sentenceItems = sentence.map {
            senditWord in
            URLQueryItem(name: "SendIt_Sentence", value: String(describing: senditWord))
        }
        
        items.append(contentsOf: sentenceItems)
        
        
        // Game Complete
        let complete = isComplete ? "1" : "0"
        
        let completeItem = URLQueryItem(name: "Is_Complete", value: complete)
        
        items.append(completeItem)
        
        //current player
        let player = currentPlayer
        
        let playerItem = URLQueryItem(name: "currentPlayer", value: player)
        
        items.append(playerItem)
        
        
        //countdown timer starter
        let sec  = second
        
        let secondItem = URLQueryItem(name: "second", value: sec)
        
        items.append(secondItem)
        
        //# of rounds
        let rod  = rounds
        
        let roundItem = URLQueryItem(name: "rounds", value: rod)
        
        items.append(roundItem)
        
        //initial sentenceStarter
        let starter  = starterSent
        
        let starterItem = URLQueryItem(name: "starter", value: starter)
        
        items.append(starterItem)
        
        
        //adds components of items to components
        components.queryItems = items
        
        //url has components
        guard let url = components.url else {
            fatalError("Invalid URL components")

        }
        return url
    }

}


//extension that initiates a SenditSentence Object
extension SenditSentence {
    init?(from url: URL) {
        // Parse the url
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let componentItems = components.queryItems else {
                fatalError("Invalid message url")
        }
        
        // Naïvely retrieve the send it sentence from the URL
        sentence = componentItems.filter({ $0.name == "SendIt_Sentence" }).map({ String($0.value!)! })
        
        //Even more naïvely retrieve game completion stat
        let completeQueryItem = componentItems.filter({ $0.name == "Is_Complete" }).first!
        isComplete = completeQueryItem.value! == "1"
        
        //naïvely retrieves current player
        let playerQueryItem = componentItems.filter({ $0.name == "currentPlayer" }).first!
        currentPlayer = playerQueryItem.value!
        
        //naïvely retrieves the starter countdown time
        let secondQueryItem = componentItems.filter({ $0.name == "second" }).first!
        second = secondQueryItem.value!
        
        //naïvely retrieves # of rounds
        let roundQueryItem = componentItems.filter({ $0.name == "rounds" }).first!
        rounds = roundQueryItem.value!
        
        //naïvely retrieves SenditSentence Starter for Snapshot
        let sentQueryItem = componentItems.filter({ $0.name == "starter" }).first!
        starterSent =  sentQueryItem.value!
        
    }
    
}

//extension SenditSentence Model
extension SenditSentence {
    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        self.init(from: messageURL)
    }
}



