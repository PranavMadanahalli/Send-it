//
//  CustomizeViewController.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/6/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit

class CustomizeViewController: UIViewController {
    
    static let storyboardIdentifier = "CustomizeViewController"


    @IBOutlet var segControl: UISegmentedControl!
    
    var random: Bool!
    var timeHomie: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        random = true
        timeHomie = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    var onButtonTap: ((Void) -> Void)?
    
    @IBAction func startGame(_ sender: AnyObject){
       
            onButtonTap?()
            sendData()
        
    }
    
    @IBAction func getInfo(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Version 1.0", message: "Add a word before the timer ends. Puncuation completes the sentence.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("OK Pressed")
        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func sendData()-> String{
        
        //return textField.text!+" "+String(random)

        return String(random) + " " + String(timeHomie)
    }
    
    
    @IBAction func timeChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            
            timeHomie = 10
        }
        if sender.selectedSegmentIndex == 1{
            
            timeHomie = 15

            
        }
        if sender.selectedSegmentIndex == 2{
            
            timeHomie = 30

        
        }
        
    }
    @IBAction func segDelta(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            
            random  = true
            
        }
        else{
            
            random  = false
            
        }
    }

}
