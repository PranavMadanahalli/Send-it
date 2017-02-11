//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Pranav Madanahalli on 2/3/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    var seconds: Int = 15
    
    var random: Bool = true
    
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
    
    
    func getSeconds()-> Int{
        return seconds
    }
    func getRandom()-> Bool{
        return random
    }
    
    
    
    private func presentChildViewController(for presentationStyle: MSMessagesAppPresentationStyle, with conversation: MSConversation){
        
        
        var controller = UIViewController()
        if presentationStyle == .compact {
            
            controller = instantiateStartSenditViewController()
            
        }
        else {
            if let message = conversation.selectedMessage,
                let url = message.url {
                let model = SenditSentence(from: url)
                controller = instantiateBuildSenditViewController(with: conversation, model: model!)
            }
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
    func instantiateStartSenditViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "StartSenditViewController") as? StartSenditViewController else {
            fatalError("Cannot instantiate view controller")
        }
        
        controller.onButtonTap = {
            [unowned self] in
            
            self.requestPresentationStyle(.expanded)
            
        }
        
        controller.onCustoTap = {
            [unowned self] in
            self.customizeMethod()
        }
        
        return controller
    }

    private func instantiateStartBuildingSenditViewController(with conversation: MSConversation, randomStart: Bool, secondStart: Int) -> UIViewController {
        // Instantiate a `BuildIceCreamViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier:StartBuildingViewController.storyboardIdentifier) as? StartBuildingViewController else { fatalError("Unable to instantiate a BuildIceCreamViewController from the storyboard") }
        
        controller.setCurrentPlayer(player: "\(conversation.localParticipantIdentifier)")
        
        controller.setSeconds(second: secondStart)
        controller.setRandom(randoms: randomStart)
        
        controller.onLocationSelectionComplete = {
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
            

            
            if let message = conversation.selectedMessage,
                let session = message.session {
                let player = "$\(conversation.localParticipantIdentifier)"
                let caption = playerWon ? "\(player) couldn't Send it." : "\(player) lost!"
                
                self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
            }
            
            self.dismiss()
        }

        return controller
    }
    
    
    private func instantiateBuildSenditViewController(with conversation: MSConversation, model: SenditSentence) -> UIViewController {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: BuildSenditViewController.storyboardIdentifier) as? BuildSenditViewController else { fatalError("Unable to instantiate a BuildIceCreamViewController from the storyboard") }
        
        controller.initModel = model
        controller.currentPlayer(playerUID: "\(conversation.localParticipantIdentifier)")
        
        controller.setSeconds(sec: Int(model.second)!)
       
        
        
        
        if (model.isComplete) {
            
            controller.allowToView()
            
            let alert = UIAlertController(title: "Sentence Complete.", message: "send another one.", preferredStyle: .alert)
            present(alert, animated: true)
            
            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                
            }
            
            alert.addAction(okAction)
            
            // Present the controller
            self.present(alert, animated: true, completion: nil)
            
            
            return controller
            
        }
        else if(model.currentPlayer != "\(conversation.localParticipantIdentifier)"){
            
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
            
            controller.onLocationSelectionComplete = {
                [unowned self]
                model, snapshot in
            
                let session = conversation.selectedMessage?.session ?? MSSession()
                let caption = "Add a word."
            
                self.insertMessageWith(caption: caption, model, session, snapshot, in: conversation)
                
                self.dismiss()
                
            }
            
            return controller
            
        }
        else {
            
            guard let controller = storyboard?.instantiateViewController(withIdentifier: BuildSenditViewController.storyboardIdentifier) as? BuildSenditViewController else { fatalError("Unable to instantiate a BuildIceCreamViewController from the storyboard") }
            
            controller.initModel = model
            controller.currentPlayer(playerUID: "\(conversation.localParticipantIdentifier)")
            
            controller.setSeconds(sec: Int(model.second)!)
            
            //guard let controller = storyboard?.instantiateViewController(withIdentifier: "StartSenditViewController") as? StartSenditViewController else {fatalError("Cannot instantiate view controller")}
            
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
        
        // Now we've constructed the message, insert it into the conversation
        conversation.insert(message)
    }
}
