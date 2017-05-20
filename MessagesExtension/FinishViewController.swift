//
//  FinishViewController.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/10/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit

class FinishViewController: UIViewController {

    //textView that displays final SenditSentence
    @IBOutlet var textView: UITextView!
    
    //final SenditSentnce model
    var initModel: SenditSentence!

    static let storyboardIdentifier = "FinishViewController"

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets textView text to SenditSentence model sentence array
        textView.text = initModel.sentence.joined(separator: " ")
    }
    //if 'more info' button is pressed it displays customizable info
    @IBAction func moreInfo(_ sender: Any) {
        let alertController = UIAlertController(title: "Customize.", message: "Try clicking customize next time you start another Send it game.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
        }
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
