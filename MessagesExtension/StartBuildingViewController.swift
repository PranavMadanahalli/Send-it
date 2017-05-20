//
//  StartBuildingViewController.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/4/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import TextFieldEffects



class StartBuildingViewController: UIViewController , UITextFieldDelegate {
    
    //array of SenditStarters
    var setenceStarters: [String] = ["That feeling when ", "It would be awesome if ", "What if ","I love it when ","If only there where ","I can't believe ","Why did you ","I want to ","Everyone knows that ","I really hate it when ","Whenever ","There once was ","Once upon a time ","One time ","I have a dream that ","My favorite ", "I will ","I think ", "Remember when ", "I wish ", "Would you be mad if ","If I could, I would ", "Did you ", "If I had a million dollars, ","My mom once said, ","I would travel to ", "I dreamt that ","Odds are ","Never have I ever ","Last night ", "An explorer always brings ","It's time to ", "Dear Santa, ", "May I ","Please don't ", "I'm grateful for ","If I were president, I would ","Thank goodness there is ","I like it when ", "When I was young, ","As a child, ", "When I grow up, I want to ","If I could be an animal, I would be ", "If I could fly ", "If I were a superhero, I would ", "I worry about ", "A friend is someone who ", "A superpower I wish I could have is ", "A time I was brave was " ,"I was really scared when ", "I would like to teach everyone " , "It makes me angery when ", "A place I wish I could visit is ", "I predict that ","I just learned ", "If I was in outer space, I woud ", "Right now I want ", "When I am in my room I like to ", "If I wrote a book it would be about ", "Never in a million years ", "Whether you like it or not, " , "Although some people believe ", "On the way to ", "It wouldn't be very difficult to ", "I would prank ","I like to hear stories about ", "When someone is nice to me I ", "Right now I feel ", "What would happen if ", "I suggest that ", "I'm ready to ", "Is it just me or ","My doctor told me to ", "My dream garage would have ", "Did you break the "]
    
    //UI Elements
    static let storyboardIdentifier = "StartBuildingSenditViewController"
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: AkiraTextField!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var staticTextView: UITextView!
    
    //Timer elements
    
    var timer = Timer()
    
    var seconds: Int!
    
    var sec: Int!
    
    //sendit starters
    var random: Bool!
    var starterTemp: String!
    
    
    //sets local varibale seconds to determine what the user inputed in CustomizeViewController
    func setSeconds(second:Int){
    
        seconds = second
    
    }

    //sets local varibale random to determine what the user inputed in CustomizeViewController
    func setRandom(randoms:Bool){
        
        random = randoms
        
    }
    
    //disposeBag for Reactive Observables
    let disposeBag = DisposeBag()
    
    //starting player's UID
    var playerStartUID: String!
    
    //Completions that determine what message to construct
    var onTurnSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?
    var onTimeCompletion: ((SenditSentence,Bool, UIImage) -> Void)?
    


    
    //counts down timer
    func counter()
    {
        timeLabel.text = String(sec)
        sec! -= 1
        
        //if timer is down, save what user inputed and add another MSMessage object to MSSession. User turn is done
        if (sec == 0)
        {
            timer.invalidate()
            var model: SenditSentence?
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: String(seconds), rounds: "1", currentPlayer: playerStartUID, starterSent: starterTemp)
            let snapshot = UIImage.snapshot(from: textView)
            onTimeCompletion?(model!, true , snapshot)
            
        }
    }
    //tames the keyBoard for TextView
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
    
    //stops timer if user stops using sendit
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(StartBuildingViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StartBuildingViewController.updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        //sets initial text of TextView to be the either the custom SenditSentence Starter or one from the array setenceStarters
        staticTextView.text = starterTemp
        
        sec = seconds!
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        textField.delegate = self
        
        //reactive code to update the textView in 'real-time'
        
        //set Initial SenditSentence to a varibale
        let initSentence: Variable<String>;
        
        //if random is false, then picks a random starter from sentenceStarters
        if(self.random!){
            let randomIndex = Int(arc4random_uniform(UInt32(setenceStarters.count)))
            initSentence = Variable(setenceStarters[randomIndex])
                
            starterTemp = setenceStarters[randomIndex]
                
        }
        else {
            initSentence = Variable("")
        }
        //observes the word coming from the textField
        let wordObservable: Observable<String?> = self.textField.rx.text.asObservable()
        
        //observes the initial senditSentence
        let initSentenceObservable: Observable<String> = initSentence.asObservable()
        initSentenceObservable.subscribe(onNext: {(string: String) in
            print(string)
        })
        
        //creates a observable that connects both initSentenceObservable and wordObservable
        let finalSentence: Observable<String> = Observable.combineLatest(initSentenceObservable, wordObservable) { (initSent:
            String?, word: String?) -> String in
                return initSent! + word!
        }
        
        //binds the finalSentence to the textView
        finalSentence.bindTo(self.textView.rx.text).addDisposableTo(self.disposeBag)
   
        
    }
    
    //sets currently player to the one who initially created the game.
    func setCurrentPlayer(player: String){
        
        playerStartUID = player
        
    }
    //send it button
    @IBAction func sendIT(_ sender: Any) {
        
        //does not accept nothing! just send it
        if(textField.text == "" ){
            return
        }
        // you cannot put puncuation and end the game in the first turn. just send a text homie...
        if textView.text.contains(".") || textView.text.contains("!") || textView.text.contains("?"){
            
            return
        }
        else{
            //gets contents of textView and assigns to sentenceTemp
            let sentenceTemp = textView.text
            //gets an array of words based on the sentenceTemp
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            //creates a SenditSetence Model
            let model: SenditSentence!
            if  random == false {
                staticTextView.text  = "           " + textView.text + "..."
                
                model = SenditSentence(sentence: sentenceArr!, isComplete: false, second: String(seconds), rounds: "1", currentPlayer: playerStartUID, starterSent: textView.text)
            }
            else {
                staticTextView.text = "           " + starterTemp + "..."
                model = SenditSentence(sentence: sentenceArr!, isComplete: false, second: String(seconds), rounds: "1", currentPlayer: playerStartUID, starterSent: starterTemp)

            }
            onTurnSelectionComplete?(model, UIImage.snapshot(from: staticTextView))
        }
        timer.invalidate()


    }
    //no spaces in keyboard
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    //if button 'timer' button is clicked then displays information about customization
    @IBAction func timerAction(_ sender: Any) {
        timer.invalidate()

        let alertController = UIAlertController(title: "", message: "customize in main menu", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
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
            NSLog("OK Pressed")
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
            NSLog("OK Pressed")
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)

            
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

//extension to handle the gameCompletion
extension StartBuildingViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        //let finalNumber = (sentenceArr?.count)! - startingNumber
        
        model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: String(seconds), rounds: "1", currentPlayer: playerStartUID, starterSent: starterTemp)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }

}
