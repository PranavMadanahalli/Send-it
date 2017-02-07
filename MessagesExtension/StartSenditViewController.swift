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
    
    @IBAction func startGame(_ sender: AnyObject) {
        onButtonTap?()
    }
    @IBAction func customize(_ sender: AnyObject) {
        onCustoTap?()
    }
    
    
    
    
 
}
