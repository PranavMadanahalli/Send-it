//
//  StartSenditViewController.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/3/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit

class StartSenditViewController: UIViewController {
    
    var onButtonTap: ((Void) -> Void)?
    
    var onCustoTap: ((Void) -> Void)?
    
    //goes to StartBuidlingViewController if "Send it" button is clicked
    @IBAction func startGame(_ sender: AnyObject) {
        onButtonTap?()
    }
    //goes to CustomizeViewController if "Customize" button is clicked
    @IBAction func customize(_ sender: AnyObject) {
        onCustoTap?()
    }
    
    
    
    
 
}
