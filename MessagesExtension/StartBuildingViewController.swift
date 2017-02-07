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
    
    var setenceStarters: [String] = ["That feeling when ", "It would ", "What if ","I love ","I like ","All ","If only ","If ","I can't ","Why ","How ","I want ","Everything ","I hate ","Whenever ","There once was ","Once upon a time ","One time ","I have a dream that ","My favorite "]
    
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
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: String(seconds), currentPlayer: playerStartUID)
            let snapshot = UIImage.snapshot(from: textView)
            
            onTimeCompletion?(model!, true , snapshot)

            
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sec = seconds!

        timer.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        //textView.setContentOffset(CGPoint.init(x: 0.0, y: 15.0), animated: false)

        textField.delegate = self
        
        let initSentence: Variable<String>;
        if(random!){
            let randomIndex = Int(arc4random_uniform(UInt32(setenceStarters.count)))
            initSentence = Variable(setenceStarters[randomIndex])
        }
        else {
            initSentence = Variable("")
        }
    

        
        //magic happens here
        let wordObservable: Observable<String?> = textField.rx.text.asObservable()
        let initSentenceObservable: Observable<String> = initSentence.asObservable()
        initSentenceObservable.subscribe(onNext: {(string: String) in
            print (string)
        
        })
        let finalSentence: Observable<String> = Observable.combineLatest(initSentenceObservable, wordObservable) { (initSent: String?, word: String?) -> String in
            return initSent! + word!
        }
        finalSentence.bindTo(textView.rx.text).addDisposableTo(disposeBag)
        
        
        
    }
    
    func setCurrentPlayer(player: String){
        
        playerStartUID = player
        
    }
    
    @IBAction func sendIt(_ sender: Any) {
        
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
        
            let model = SenditSentence(sentence: sentenceArr!, isComplete: false, second: String(seconds), currentPlayer: playerStartUID)
        
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
    
}

extension StartBuildingViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: String(seconds), currentPlayer: playerStartUID)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }

}
