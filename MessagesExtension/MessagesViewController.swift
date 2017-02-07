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
    
    
    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)
        
        
        presentChildViewController(for: presentationStyle, with: conversation)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let conversation = self.activeConversation else { return }
        super.willTransition(to: presentationStyle)
        

        presentChildViewController(for: presentationStyle, with: conversation)
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
                controller = instantiateStartBuildingSenditViewController(with: conversation)
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
    func instantiateStartSenditViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "StartSenditViewController") as? StartSenditViewController else {
            fatalError("Cannot instantiate view controller")
        }
        
        controller.onButtonTap = {
            [unowned self] in
            

            self.requestPresentationStyle(.expanded)
            
        }
        
        
        
        return controller
    }

    private func instantiateStartBuildingSenditViewController(with conversation: MSConversation) -> UIViewController {
        // Instantiate a `BuildIceCreamViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier:StartBuildingViewController.storyboardIdentifier) as? StartBuildingViewController else { fatalError("Unable to instantiate a BuildIceCreamViewController from the storyboard") }
        
        controller.setCurrentPlayer(player: "\(conversation.localParticipantIdentifier)")
        
        
        
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
        
        
        
        if(model.currentPlayer != "\(conversation.localParticipantIdentifier)"){
            controller.currentPlayer(playerUID: "\(conversation.localParticipantIdentifier)")

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
        else if (model.isComplete) {
            
            let alert = UIAlertController(title: "Impromptu session complete.", message: "send another one.", preferredStyle: .alert)
            present(alert, animated: true)
            
            return controller
            
        }
        else {
            
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "StartSenditViewController") as? StartSenditViewController else {
                fatalError("Cannot instantiate view controller")}
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
