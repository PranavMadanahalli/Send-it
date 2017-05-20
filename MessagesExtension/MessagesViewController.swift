//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Pranav Madanahalli on 2/3/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit
import Messages

//controls the presentation of the multiple view controllers:
// .compact: 'StartSenditViewControler' & 'CustomizeViewController'
// .expanded: 'StartBuidlingSenditViewController' , 'BuildSenditViewController' & 'FinishViewController'
class MessagesViewController: MSMessagesAppViewController {
    
    //default time limit to send a word
    var seconds: Int = 15

    //true if user picked random SendItSentence Starter, or false if they are customizing their own starter
    var random: Bool = true
    
    //sets seconds timer and random
    func parseCustom(string: String){
        let sentenceArr = string.components(separatedBy: " ")
        
        if (sentenceArr[0] == "true"){
            random = true
        }
        else{
            random = false
        }
        seconds = Int(sentenceArr[1])!
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)
        presentChildViewController(for: presentationStyle, with: conversation)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = self.activeConversation else { return }
        super.willTransition(to: presentationStyle)
        presentChildViewController(for: presentationStyle, with: conversation)
    }
    
    //getter method for current seconds left
    func getSeconds()-> Int{
        return seconds
    }
    //getter method for random
    func getRandom()-> Bool{
        return random
    }
    
    
    private func presentChildViewController(for presentationStyle: MSMessagesAppPresentationStyle, with conversation: MSConversation){
        var controller = UIViewController()
        
        //.compact is the small view when user is starting a Send it game. View takes up the keyboard section of iMessage App
        if presentationStyle == .compact {
            
            //instantiateStartSenditViewController
            controller = instantiateStartSenditViewController()
            
        }
        //if user is continuing a game or wants to start a game then they are presented a view that fills the whole screen. This is usually StartBuildingSenditViewController or BuildSenditViewController
        else {
            //if there is a current game then get SenditSentence model in order to fill BuildSenditViewController with the sentence and round count.
            if let message = conversation.selectedMessage, let url = message.url {
                let model = SenditSentence(from: url)
                controller = instantiateBuildSenditViewController(with: conversation, model: model!)
            }
            // if there is no current game then user wants to start a game. Present StartBuildingSenditViewController
            else {
                controller = instantiateStartBuildingSenditViewController(with: conversation, randomStart: getRandom() , secondStart: getSeconds())
            }
        }
        
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller.
        addChildViewController(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controller.didMove(toParentViewController: self)
    
    
    }
    func customizeMethod(){
        var controller = UIViewController()
            controller = instantiateCustom()
        
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        // Embed the new controller.
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    
    
    }
    
    // Instantiate a `CustomizeViewController` and present it.
    func instantiateCustom()-> UIViewController{
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "CustomizeViewController") as? CustomizeViewController else {
            fatalError("Cannot instantiate view controller")
        }
        controller.onButtonTap = {
            [unowned self] in
            
            self.parseCustom(string: controller.sendData())
            self.requestPresentationStyle(.expanded)
        }
        return controller
    }
    
    // Instantiate a `StartSenditViewController` and present it.
    func instantiateStartSenditViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "StartSenditViewController") as? StartSenditViewController else {
            fatalError("Cannot instantiate view controller")
        }
        
        //if user clicks Send it then present StartBuildingSenditViewController
        controller.onButtonTap = {
            [unowned self] in
            self.requestPresentationStyle(.expanded)
            
        }
        
        //if user clicks customize then present CustomizeViewController
        controller.onCustoTap = {
            [unowned self] in
            self.customizeMethod()
        }
        
        return controller
    }
    
    // Instantiate a `StartBuildingSenditViewController` and present it.
    private func instantiateStartBuildingSenditViewController(with conversation: MSConversation, randomStart: Bool, secondStart: Int) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier:StartBuildingViewController.storyboardIdentifier) as? StartBuildingViewController else { fatalError("Unable to instantiate a StartBuildingViewController from the storyboard") }
        
        //accessing StartBuildingSenditViewController setter methods
        controller.setCurrentPlayer(player: "\(conversation.localParticipantIdentifier)")
        controller.setSeconds(second: secondStart)
        controller.setRandom(randoms: randomStart)
        
        //once user is done with first part of Send it
        controller.onTurnSelectionComplete = {
            [unowned self]
            model, snapshot in
            let session = MSSession()
            //let caption = "$\(conversation.localParticipantIdentifier) wants to play Send it! Add a word."
            let caption = "Let's play Send it!"
            self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
            self.dismiss()
        }
        
        controller.onGameCompletion = {
            [unowned self]
            model, playerWon, snapshot in
            
            if let message = conversation.selectedMessage,
                let session = message.session {
                let player = "$\(conversation.localParticipantIdentifier)"
                let caption = playerWon ? "\(player) ended it." : "\(player) lost!"
                
                self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
            }
            
            self.dismiss()
        }
        
        controller.onTimeCompletion = {
            [unowned self]
            model, playerWon, snapshot in
            
            let number = Int(model.rounds)

            
            if let message = conversation.selectedMessage,
                let session = message.session {
                let player = "$\(conversation.localParticipantIdentifier)"
                let caption = playerWon ? "\(player) couldn't Send it. \(number!) rounds." : "\(player) lost!"
                
                self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
            }
            
            self.dismiss()
        }

        return controller
    }
    
    // Instantiate a `BuildSenditViewController` and present it.
    private func instantiateBuildSenditViewController(with conversation: MSConversation, model: SenditSentence) -> UIViewController {
        //if SenditSentence setence is saying that game is over then present FinishViewController
        if (model.isComplete) {
            
            guard let controller = storyboard?.instantiateViewController(withIdentifier: FinishViewController.storyboardIdentifier) as? FinishViewController else { fatalError("Unable to instantiate a BFinishViewController from the storyboard") }
            controller.initModel = model
            return controller
            
        }
        
        else if(model.currentPlayer != "\(conversation.localParticipantIdentifier)"){
            guard let controller = storyboard?.instantiateViewController(withIdentifier: BuildSenditViewController.storyboardIdentifier) as? BuildSenditViewController else { fatalError("Unable to instantiate a BuildSenditViewController from the storyboard") }
            
            //accessing BuildSenditViewController setter methods
            controller.initModel = model
            controller.currentPlayer(playerUID: "\(conversation.localParticipantIdentifier)")
            controller.setSeconds(sec: Int(model.second)!)
            
            //if model says game is completed, then construct a message with a completed game caption
            controller.onGameCompletion = {
                [unowned self]
                modelS, playerWon, snapshot in
                
                var number = Int(modelS.rounds)
                
                number = number! - 1
                
                if let message = conversation.selectedMessage,
                    let session = message.session {
                    let player = "$\(conversation.localParticipantIdentifier)"
                    let caption = playerWon ? "\(player) ended it. \(number!) rounds." : "\(player) lost!"
                    
                    self.insertMessageWith(caption: caption, modelS, session, snapshot, in: conversation)
                }
                
                self.dismiss()
            }
            
            //if user could not send it in time (game ends) then construct a message stating player could not send it in time
            controller.onTimeCompletion = {
                [unowned self]
                modelT, playerWon, snapshot in
                
                var number = Int(modelT.rounds)
                
                number = number! - 1
                
                if let message = conversation.selectedMessage,
                    let session = message.session {
                    let player = "$\(conversation.localParticipantIdentifier)"
                    let caption = playerWon ? "\(player) couldn't Send it. \(number!) rounds." : "\(player) lost!"
                    self.insertMessageWith(caption: caption, modelT, session, snapshot, in: conversation)
                    
                }
                self.dismiss()
            }
            
            //if user successfully sent it then construct message for other player to respond to!
            controller.onTurnSelectionComplete = {
                [unowned self]
                model, snapshot in
                let session = conversation.selectedMessage?.session ?? MSSession()
                let caption = "Add a word."
                self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
                self.dismiss()
            }
            return controller
        }
        //if it is not the user's turn then, present BuildSenditViewController with limitations
        else {
            guard let controller = storyboard?.instantiateViewController(withIdentifier: BuildSenditViewController.storyboardIdentifier) as? BuildSenditViewController else { fatalError("Unable to instantiate a BuildSenditViewController from the storyboard") }
            controller.initModel = model
            controller.currentPlayer(playerUID: "\(conversation.localParticipantIdentifier)")
            controller.setSeconds(sec: Int(model.second)!)
            controller.setTimerYes(ba: false)
            let alert = UIAlertController(title: "Waiting for opponent...", message: "", preferredStyle: .alert)
            present(alert, animated: true)
            return controller
        }
    }
}
extension MessagesViewController {
    /// Constructs a message and inserts it into the conversation
    func insertMessageWith(caption: String,
                           _ model: SenditSentence,
                           _ session: MSSession,
                           _ image: UIImage,
                           in conversation: MSConversation) {
        let message = MSMessage(session: session)
        let template = MSMessageTemplateLayout()
        template.image = image
        template.caption = caption
        message.summaryText = "Send it"
        message.layout = template
        message.url = model.encode()
        
        //insert it into the conversation
        conversation.insert(message)
    }
}
