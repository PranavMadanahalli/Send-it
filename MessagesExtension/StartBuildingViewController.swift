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
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: AkiraTextField!
    
    
    let disposeBag = DisposeBag()
    
    
    var playerStartUID: String!
    
    
    var onLocationSelectionComplete: ((SenditSentence, UIImage) -> Void)?
    
    
    var onGameCompletion: ((SenditSentence, Bool, UIImage) -> Void)?


    static let storyboardIdentifier = "StartBuildingSenditViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        textView.setContentOffset(CGPoint.zero, animated: false)

        textField.delegate = self
        
        let initSentence: Variable<String> = Variable("       That feeling when ")
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setCurrentPlayer(player: String){
        
        playerStartUID = player
        
    }
    
    @IBAction func sendIt(_ sender: Any) {
        if textView.text.contains("."){
            
            gameCompletionFunc()
            
        }
        else{
            let sentenceTemp = textView.text
        
            let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
            let model = SenditSentence(sentence: sentenceArr!, isComplete: false, currentPlayer: playerStartUID)
        
            // Clear screen for snapshot (we don't want to give away where we've located our ships!)
            
            onLocationSelectionComplete?(model, UIImage.snapshot(from: textView))
        }
    }
    
}

extension StartBuildingViewController {
    func gameCompletionFunc() {
        
        var model: SenditSentence?
        let sentenceTemp = textView.text
        let sentenceArr = sentenceTemp?.components(separatedBy: " ")
        
        model = SenditSentence(sentence: sentenceArr!, isComplete: true, currentPlayer: playerStartUID)
        let snapshot = UIImage.snapshot(from: textView)
        onGameCompletion?(model!, true, snapshot)
        
    }

}
