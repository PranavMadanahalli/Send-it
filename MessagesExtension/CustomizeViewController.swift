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
    
    
    //boolean that determines if Send it starts with a random or custom sentence starter
    var random: Bool!
    //int that keeps track of the starting countdown timer value
    var timeHomie: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //defualt random is true and 15 second timer
        random = true
        timeHomie = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    var onButtonTap: ((Void) -> Void)?
    
    //when 'send it' button is pressed values for timerHomie and random get transfered to StartBuidlingSenditViewController
    @IBAction func startGame(_ sender: AnyObject){
        onButtonTap?()
        print(sendData())
        
    }
    
    func sendData()-> String{
        
        return String(random) + " " + String(timeHomie)
    }
    //recognized the segmented control changes and sets timeHomie to values selected by user
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
    //recognized the random segmented control changes and sets random to values selected by user
    @IBAction func segDelta(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            random  = true
            
        }
        else{
            random  = false
            
        }
    }

}
