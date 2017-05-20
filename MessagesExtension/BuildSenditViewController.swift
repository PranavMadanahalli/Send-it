//
//  BuildSenditViewController.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/4/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit
import TextFieldEffects
import SwiftyButton

//Reactive necessities
import RxSwift
import RxCocoa


//most used viewcontrolle. It controlls the adding of words to the SenditSentence
class BuildSenditViewController: UIViewController , UITextFieldDelegate {
    
    //UI elements
    static let storyboardIdentifier = "BuildSenditViewController"
    @IBOutlet var button: PressableButton!
    @IBOutlet var textField: AkiraTextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var roundLabel: UILabel!
    @IBOutlet var staticTextView: UITextView!

    
    
    var timer = Timer()
    
    //variable that holds the seconds left on the timer
    var seconds: Int!
    
    //true: timer is active. false: timer is inactive
    var timerYes: Bool = true
    
    //setter method for timerYes
    func setTimerYes(ba: Bool){
        timerYes = ba
    }
    //setter method of seconds
    func setSeconds(sec:Int){
        seconds = sec
        
    }
    
    //starting sendit Sentence. Used in SenditSentence Model to determine the Snapshot that goes into the Message
    var starterTemp: String!
    
  
    
    let disposeBag = DisposeBag()
    
    //Completions that determine what message to construct
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?
    var onTurnSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    var onTimeCompletion: ((SenditSentence,Bool, UIImage) -> Void)?
    
    //SenditSentence Model
    var initModel: SenditSentence!
    
    //name of current user
    var playerBOI: String!
    
    //starting number of timer. Used in Model to dertermine a custom time countdown.
    var startingNumber: Int!

    //method that counts down timer
    func counter(){
        timeLabel.text = String(seconds)
        seconds! -= 1
        
        //if timer runs out complete onTimeCompletion
        if (seconds == 0){
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
    
    //tames the textView
    func updateTextView (notification:Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            textView.contentInset = UIEdgeInsets.zero
        }
        else{
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
            
            textView.scrollIndicatorInsets = textView.contentInset
        }
        textView.scrollRangeToVisible(textView.selectedRange)
   
    }
   
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tames the keyBoard a little :D
        NotificationCenter.default.addObserver(self, selector: #selector(BuildSenditViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BuildSenditViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        //sets startingNumber and starterTemp to the value in the game's SenditSetence model
        startingNumber = Int(initModel.rounds)
        starterTemp = initModel.starterSent
        

        
        
        timer.invalidate()
        
        //if timerYes is true diplay round staticTextView and roundLabel
        if(timerYes){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
            roundLabel.text = "rounds: " + "\(startingNumber!)"
            staticTextView.text = "           " + starterTemp + "..."

            
        }
        else{
            staticTextView.isHidden = true
        
        }
        textField.delegate = self
        
        
        //reactive code to update the textView in 'real-time'
        
        //set Initial SenditSentence to a varibale
        let initSentence: Variable<String> = Variable(initModel.sentence.joined(separator: " ") + " ")
        
        //observes the word coming from the textField
        let wordObservable: Observable<String?> = textField.rx.text.asObservable()
        
        //observes the initial senditSentence
        let initSentenceObservable: Observable<String> = initSentence.asObservable()
            initSentenceObservable.subscribe(onNext: {(string: String) in
        })
        
        //creates a observable that connects both initSentenceObservable and wordObservable
        let finalSentence: Observable<String> = Observable.combineLatest(initSentenceObservable, wordObservable) { (initSent: String?, word: String?) -> String in
                
            return initSent! + word!
                
        }
        //binds the finalSentence to the textView
        finalSentence.bindTo(textView.rx.text).addDisposableTo(disposeBag)
       
        
    }
    //doesn't allow spaces in the textField (users can only add one word
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    func currentPlayer(playerUID: String){
        
        playerBOI = playerUID
        
    }
    //if button 'timer' button is clicked then displays information about customization
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
    //if 'be creative.' button is clicked then display a nice quote to inspire the user!
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
    //if 'punctuation ends the game' button is clicked display a quick rule to the game
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
    //send it button
    @IBAction func sendIt(_ sender: Any) {
        //if user does
        if(textField.text == ""){
            return
        }
        //if textView contains puncuation then complete gameCompletion
        if textView.text.contains(".") || textView.text.contains("!") || textView.text.contains("?"){
            gameCompletionFunc()
            
        }
        else {
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            var model: SenditSentence?
            
            startingNumber = startingNumber! + 1
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: false,second: initModel.second,rounds: String(startingNumber), currentPlayer: playerBOI, starterSent: starterTemp)
            
            onTurnSelectionComplete?(model!, UIImage.snapshot(from: staticTextView))
            
        }
        timer.invalidate()

    }
    
    
}
//extension handles the completion of gameCompletion Completion
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


