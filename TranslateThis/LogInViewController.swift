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

    @IBOutlet weak var userNameInput: UITextField!
    
    @IBAction func translateThis(_ sender: UIButton) {
        
        let username = userNameInput.text
        
        
        
        performSegue(withIdentifier: "LoginSegue", sender: username)
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
        
        let greeting = "Greetings! Please provide a Username below."
        self.speak(string: greeting)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

