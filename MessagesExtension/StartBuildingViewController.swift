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
    
    var setenceStarters: [String] = ["         That feeling when ", "         It would ", "         What if ","         I love ","         I like ","        All ","          If only ","       If ","         I can't ","         Why ","         How ","         I want ","         Everyone knows that ","         I hate ","         Whenever ","       There once was ","         Once upon a time ","         One time ","         I have a dream that ","         My favorite ", "         Yesterday ", "         Tomorrow ", "         I will ", "         Something ","         I think ", "         Remember when ", "         I wish ", "         Would you be mad if ","         If I could, I would ", "         Did you ", "         If I had a million dollars, ","         My mom once said, ","         I would travel to ", "         I dreamt ","         Odds are ","         Never have I ever ","         Everyone knows that ","         Last night ", "         An explorer always brings ","         It's time to ", "         Dear Santa, ", "         May I ","         Please don't ", "         I am grateful for ","         If I were president, I would ","         Thank goodness there is ","         I like it when ", "         When I was young, ","         As a child, ", "         When I grow up, I want to ","         If I could be an animal, I would be ", "         If I could fly ", "         If I were a superhero, I would ", "         I worry about ", "         A friend is someone who ", "         A superpower I wish I could have is ", "         A time I was brave was ","         I was really scared when ", "         I would like to teach everyone " , "         It makes me angery when ", "         I place I wish I could visis is ","         If I had three wishes ", "         I predict that ","         I just learned ", "         If I was in outer space, I woud ", "         Right now I want ", "         When I am in my room I like to ", "         If I wrote a book it would be about ", "         I can show respect by ", "         Never in a million years ", "         Whether you like it or not, " , "         Although some people believe ", "         On the way to ", "         Here are two reasons why ", "         It wouldn't be very difficult to ", "         I would prank ","         I like to hear stories about ", "         When someone is nice to me I ", "         Right now I feel ", "         What would happen if ", "         I suggest that "]
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: AkiraTextField!
    
    @IBOutlet var timeLabel: UILabel!
    
     var timer = Timer()
    
    var seconds: Int!
    
    var random: Bool!
    
    var sec: Int!
   
    func setSeconds(second:Int){
    
        seconds = second
    
    }
    func setRandom(randoms:Bool){
        
        random = randoms
        
    }
    

    let disposeBag = DisposeBag()
    
    
    var playerStartUID: String!
    
    
    var onLocationSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    
    
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?
    
    var onTimeCompletion: ((SenditSentence,Bool, UIImage) -> Void)?
    
   // var startingNumber: Int = 0



    static let storyboardIdentifier = "StartBuildingSenditViewController"
    
    
    func counter()
    {
        timeLabel.text = String(sec)
        sec! -= 1

        if (sec == 0)
        {
            timer.invalidate()
            var model: SenditSentence?
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
           //  let finalNumber = (sentenceArr?.count)! - startingNumber
            model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: String(seconds), rounds: "1", currentPlayer: playerStartUID)
            let snapshot = UIImage.snapshot(from: textView)
            
            onTimeCompletion?(model!, true , snapshot)
            
        }
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
        
        sec = seconds!
        
        timer.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        
        textField.delegate = self
        
        
       
            
            
            let initSentence: Variable<String>;
            
            if(self.random!){
                let randomIndex = Int(arc4random_uniform(UInt32(setenceStarters.count)))
                initSentence = Variable(setenceStarters[randomIndex])
                
                //let sentenceArr = String(describing: initSentence).components(separatedBy: " ")
                //startingNumber = sentenceArr.count
                
            }
            else {
                initSentence = Variable("         ")
            }
            
        
            //magic happens here
            let wordObservable: Observable<String?> = self.textField.rx.text.asObservable()
            let initSentenceObservable: Observable<String> = initSentence.asObservable()
            initSentenceObservable.subscribe(onNext: {(string: String) in
                print (string)
                
            })
            let finalSentence: Observable<String> = Observable.combineLatest(initSentenceObservable, wordObservable) { (initSent: String?, word: String?) -> String in
                return initSent! + word!
            }
            finalSentence.bindTo(self.textView.rx.text).addDisposableTo(self.disposeBag)
            

        
        
        
        
        
    }
    
    func setCurrentPlayer(player: String){
        
        playerStartUID = player
        
    }
    
    @IBAction func sendIT(_ sender: Any) {
        if(textField.text == "" ){
            return
        }
        
        timer.invalidate()
        
        if textView.text.contains(".") || textView.text.contains("!") || textView.text.contains("?"){
            
            gameCompletionFunc()
            
        }
        else{
            
            let sentenceTemp = textView.text
            
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            //let finalNumber = (sentenceArr?.count)! - startingNumber
            
            let model = SenditSentence(sentence: sentenceArr!, isComplete: false, second: String(seconds), rounds: "1", currentPlayer: playerStartUID)
            
            // Clear screen for snapshot (we don't want to give away where we've located our ships!)
            
            onLocationSelectionComplete?(model, UIImage.snapshot(from: textView))
        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    @IBAction func timerAction(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: "customize in main menu", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func puncuationEnds(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: ". ? ! ends the game.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func beCreative(_ sender: Any) {
        let alertController = UIAlertController(title: "Just Send it.", message: "Creativity takes courage. -- Henri Matisse", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            
        }
        
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

extension StartBuildingViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        //let finalNumber = (sentenceArr?.count)! - startingNumber
        
        model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: String(seconds), rounds: "1", currentPlayer: playerStartUID)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }

}
