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


class BuildSenditViewController: UIViewController , UITextFieldDelegate {
    // MARK: Properties
    
    static let storyboardIdentifier = "BuildSenditViewController"
    
    
    @IBOutlet var textField: AkiraTextField!
    @IBOutlet var textView: UITextView!
    
    
    @IBOutlet var timeLabel: UILabel!
    
    var timer = Timer()
    
    var seconds: Int!
    
    
    
   
    func setSeconds(sec:Int){
        
        seconds = sec
        
    }
    
    
    let disposeBag = DisposeBag()
    
    
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?
    
    var onLocationSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    
    var onTimeCompletion: ((SenditSentence,Bool, UIImage) -> Void)?
    

    var initModel: SenditSentence!
    
    var playerBOI: String!
    
    
    
    
    // MARK: UIViewController
    func counter()
    {
        seconds! -= 1
        timeLabel.text = String(seconds)
        if (seconds == 0)
        {
            timer.invalidate()
            var model: SenditSentence?
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: initModel.second, currentPlayer: playerBOI)
            let snapshot = UIImage.snapshot(from: textView)
            
            onTimeCompletion?(model!, true , snapshot)
            
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.setContentOffset(CGPoint.init(x: 0.0, y: 15.0), animated: false)
        timer.invalidate()

        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)

        self.automaticallyAdjustsScrollViewInsets = false
        
        textField.delegate = self
        
        if initModel.isComplete{
            
            timer.invalidate()
            textView.text = initModel.sentence.joined(separator: " ")
    
            let alert = UIAlertController(title: "Sentence Complete.", message: "send another one.", preferredStyle: .alert)
            present(alert, animated: true)
            
            
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
            
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: false,second: initModel.second, currentPlayer: playerBOI)
            
            
            onLocationSelectionComplete?(model!, UIImage.snapshot(from: textView))
            
        }
    }
    
    
}

extension BuildSenditViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        model = SenditSentence(sentence: sentenceArr!, isComplete: true, second: initModel.second, currentPlayer: playerBOI)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }
    
}


