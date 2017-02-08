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
    }
   
    func setSeconds(sec:Int){
        
        seconds = sec
        
    }
    
    @IBOutlet var roundLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    
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
            
            startingNumber = startingNumber! + 1

            timer.invalidate()
            var model: SenditSentence?
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: initModel.second, rounds: String(describing: startingNumber), currentPlayer: playerBOI)
            let snapshot = UIImage.snapshot(from: textView)
            
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        timer.invalidate()
        
        if(timerYes){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
            startingNumber = Int(initModel.rounds)
            
            roundLabel.text = "rounds: " + "\(startingNumber!)"
            
        }
        else{
            textField.isHidden = true
            button.isHidden = true
        }
        
        textField.delegate = self
        
        if initModel.isComplete{
            
            timer.invalidate()
            textView.text = initModel.sentence.joined(separator: " ")
    
            let alert = UIAlertController(title: "Sentence Complete.", message: "send another one.", preferredStyle: .alert)
            present(alert, animated: true)
            
            roundLabel.isHidden = true
            
            
            return
            
        }
        else {
        
            
            let initSentence: Variable<String> = Variable(initModel.sentence.joined(separator: " ") + " ")
            
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
    
    @IBAction func sendIt(_ sender: Any) {
        if(textField.text == ""){
            return
        }
        timer.invalidate()
        
        if textView.text.contains(".") || textView.text.contains("!") || textView.text.contains("?"){
            
            gameCompletionFunc()
            
        }
        else {
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            var model: SenditSentence?
            
            print(playerBOI)
            
            startingNumber = startingNumber! + 1

            
            model = SenditSentence(sentence: sentenceArr!, isComplete: false,second: initModel.second,rounds: String(startingNumber), currentPlayer: playerBOI)
            
            
            onLocationSelectionComplete?(model!, UIImage.snapshot(from: textView))
            
        }
    }
    
    
}

extension BuildSenditViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        startingNumber = startingNumber! + 1

        model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: initModel.second , rounds: String(startingNumber), currentPlayer: playerBOI)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }
    
}


