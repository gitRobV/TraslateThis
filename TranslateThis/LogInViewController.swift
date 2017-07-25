//
//  LogInViewController.swift
//  TranslateThis
//
//  Created by Robert on 7/18/17.
//  Copyright © 2017 Robert Villarreal. All rights reserved.
//

import UIKit
import AVFoundation

class LogInViewController: UITableViewController {
    
    
    let synthesizer = AVSpeechSynthesizer()

    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userNameInput: UITextField!
    
    @IBAction func translateThis(_ sender: UIButton) {
        
        let username = userNameInput.text
        
        if username == "" {
            userNameLabel.text = "Please enter a Valid Username"
        } else {
            performSegue(withIdentifier: "LoginSegue", sender: username)
        }
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    
    func speak(string: String) {
        let rawText = string
        let utterance = AVSpeechUtterance(string: rawText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synthesizer.speak(utterance)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabBarController = segue.destination as! UITabBarController
        let destinationViewController = tabBarController.viewControllers?[0] as! TransThisViewController
        
        destinationViewController.username = sender as? String
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        
        let greeting = "Greetings! Please provide a Username below."
        self.speak(string: greeting)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

