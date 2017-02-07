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
    func sendData()-> String{
        
        //return textField.text!+" "+String(random)

        return String(random) + " " + String(timeHomie)
    }
    
    
    @IBAction func timeChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            
            timeHomie = 11
        }
        if sender.selectedSegmentIndex == 1{
            
            timeHomie = 16

            
        }
        if sender.selectedSegmentIndex == 2{
            
            timeHomie = 31

        
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
