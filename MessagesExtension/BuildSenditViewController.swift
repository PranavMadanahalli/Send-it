//
//  BuildSenditViewController.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/4/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit
import TextFieldEffects

import RxSwift
import RxCocoa
import SwiftyButton


class BuildSenditViewController: UIViewController , UITextFieldDelegate {
    // MARK: Properties
    
    static let storyboardIdentifier = "BuildSenditViewController"
    
    @IBOutlet var button: PressableButton!
    
    @IBOutlet var textField: AkiraTextField!
    @IBOutlet var textView: UITextView!
    
    
    @IBOutlet var timeLabel: UILabel!
    
    var timer = Timer()
    
    var seconds: Int!
    
    var timerYes: Bool = true
    
    
    func setTimerYes(ba: Bool){
        timerYes = ba
        //staticTextView.isHidden = true
    }
    
   
    func setSeconds(sec:Int){
        
        seconds = sec
        
    }
    var starterTemp: String!
    
    @IBOutlet var roundLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var staticTextView: UITextView!
    
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?
    
    var onLocationSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    
    var onTimeCompletion: ((SenditSentence,Bool, UIImage) -> Void)?
    

    var initModel: SenditSentence!
    
    var playerBOI: String!
    
    var startingNumber: Int!

    
    
    // MARK: UIViewController
    func counter()
    {
        timeLabel.text = String(seconds)
        seconds! -= 1
        
        if (seconds == 0)
        {
            timer.invalidate()

            startingNumber = startingNumber! + 1

            var model: SenditSentence?
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: initModel.second, rounds: String(startingNumber), currentPlayer: playerBOI, starterSent: starterTemp)
            
            let snapshot = UIImage.snapshot(from: staticTextView)
            
            onTimeCompletion?(model!, true , snapshot)
            
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    func updateTextView (notification:Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            textView.contentInset = UIEdgeInsets.zero
        }else{
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
            
            textView.scrollIndicatorInsets = textView.contentInset
        }
        
        textView.scrollRangeToVisible(textView.selectedRange)
        
        
        
        
    }
   
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(BuildSenditViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BuildSenditViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        startingNumber = Int(initModel.rounds)
        
        starterTemp = initModel.starterSent
        

        
        
        timer.invalidate()
        
        if(timerYes){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
            
            roundLabel.text = "rounds: " + "\(startingNumber!)"
            staticTextView.text = "           " + starterTemp + "..."

            
        }else{
        
            staticTextView.isHidden = true

        
        }
        
        textField.delegate = self
        
        
        
            
        let initSentence: Variable<String> = Variable(initModel.sentence.joined(separator: " ") + " ")
            
        let wordObservable: Observable<String?> = textField.rx.text.asObservable()
            
        let initSentenceObservable: Observable<String> = initSentence.asObservable()
            initSentenceObservable.subscribe(onNext: {(string: String) in
        })
            
        let finalSentence: Observable<String> = Observable.combineLatest(initSentenceObservable, wordObservable) { (initSent: String?, word: String?) -> String in
                
        return initSent! + word!
                
        }
            finalSentence.bindTo(textView.rx.text).addDisposableTo(disposeBag)
       
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    func currentPlayer(playerUID: String){
        
        playerBOI = playerUID
        
    }
    @IBAction func timerAction(_ sender: Any) {
        timer.invalidate()

        let alertController = UIAlertController(title: "", message: "customize in main menu", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)

        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func beCreative(_ sender: Any) {
        timer.invalidate()

        let alertController = UIAlertController(title: "Just Send it.", message: "Creativity takes courage. -- Henri Matisse", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)

        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func puncuationEnds(_ sender: Any) {
        timer.invalidate()

        let alertController = UIAlertController(title: "", message: ". ? ! ends the game.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)

        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendIt(_ sender: Any) {
        if(textField.text == ""){
            return
        }
        
        
        if textView.text.contains(".") || textView.text.contains("!") || textView.text.contains("?"){
            
            gameCompletionFunc()
            
        }
        else {
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            var model: SenditSentence?
            
            print(playerBOI)
            
            startingNumber = startingNumber! + 1

            
            model = SenditSentence(sentence: sentenceArr!, isComplete: false,second: initModel.second,rounds: String(startingNumber), currentPlayer: playerBOI, starterSent: starterTemp)
            
            
            onLocationSelectionComplete?(model!, UIImage.snapshot(from: staticTextView))
            
        }
        timer.invalidate()

    }
    
    
}

extension BuildSenditViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        
        textView.text = "           " + textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        startingNumber = startingNumber! + 1

        model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: initModel.second , rounds: String(startingNumber), currentPlayer: playerBOI, starterSent: starterTemp)
        
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }
    
}


