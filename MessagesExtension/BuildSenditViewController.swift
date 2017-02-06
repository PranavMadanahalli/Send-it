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
    
    @IBOutlet weak var textField: AkiraTextField!
    @IBOutlet weak var textView: UITextView!
    
    let disposeBag = DisposeBag()
    
    
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?
    
    var onLocationSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    
    
    var initModel: SenditSentence!
    
    var playerBOI: String!
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        textField.delegate = self
        
        if initModel.isComplete {
            
            textView.text = initModel.sentence.joined(separator: " ")
    
            let alert = UIAlertController(title: "Sentence Complete.", message: "'The worst enemy to creativity is self-doubt.'― Sylvia Plath", preferredStyle: .alert)
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
        
        
        // Make sure the prompt and ice cream view are showing the correct information.
        
        /*
         We want the collection view to decelerate faster than normal so comes
         to rests on a body part more quickly.
         */
        
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
    
    @IBAction func sendITMan(_ sender: Any) {
        
        
        if textView.text.contains("."){
            
            gameCompletionFunc()
           
        }
        else {
            let sentenceTemp = textView.text
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
            
            var model: SenditSentence?
            
            print(playerBOI)
            
            
            model = SenditSentence(sentence: sentenceArr!, isComplete: false, currentPlayer: playerBOI)
            
            
            onLocationSelectionComplete?(model!, UIImage.snapshot(from: textView))
        
        }
        
        
    }
   
    
    // MARK: Interface Builder actions
    
    
}

extension BuildSenditViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        model = SenditSentence(sentence: sentenceArr!, isComplete: true, currentPlayer: playerBOI)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }
    
}


