//
//  TransThisVoiceVC.swift
//  TranslateThis
//
//  Created by Ruben Duran on 7/25/17.
//  Copyright © 2017 Robert Villarreal. All rights reserved.
//

import Speech
import AVFoundation
import Foundation
import UIKit

class TransThisVoiceVC: UIViewController, SFSpeechRecognizerDelegate {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var audioPlayer: AVAudioPlayer!
    var recording = false
    
    
    @IBOutlet weak var resulsLabel: UILabel!
    @IBOutlet weak var passedIn: UILabel!
    @IBOutlet weak var thePhrase: UITextField!
    
    
    @IBOutlet weak var recordButton: UIButton!


    @IBAction func recordButtonPressed(_ sender: UIButton) {
            if recording {
                audioEngine.stop()
                if let node = audioEngine.inputNode {
                    node.removeTap(onBus: 0)
                }
                recognitionTask?.cancel()
                recordButton.backgroundColor = UIColor.red
                recording = false
            } else if !recording {
                self.recordAndRecognizeSpeech()
                recordButton.backgroundColor = UIColor.green
                recording = true
            }
        }
    
    
    @IBAction func translateThis(_ sender: UIButton) {
    
            if let toBeTranaslated = thePhrase.text {
                let newToBeTranslated = toBeTranaslated.replacingOccurrences(of: " ", with: "+")
                let languaged = "es"
                print(newToBeTranslated)
                let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=AIzaSyCxfmolIMWqxSLSJZXvBCkT1gmNKrbDRvQ&q=" + newToBeTranslated + "&target=" + languaged)
                // create a URLSession to handle the request tasks
                let session = URLSession.shared
                // create a "data task" to make the request and run completion handler
                let task = session.dataTask(with: url!, completionHandler: {
                    // see: Swift closure expression syntax
                    data, response, error in
                    // data -> JSON data, response -> headers and other meta-information, error-> if one occurred
                    // "do-try-catch" blocks execute a try statement and then use the catch statement for errors
                    do {
                        // try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                            print(jsonResult)
                            let data = jsonResult["data"] as! NSDictionary
                            print(data)
                            let transl = data["translations"] as! NSArray
                            let translationDict = transl[0] as! NSDictionary
                            let translatedText = translationDict["translatedText"] as! String
                            print(translatedText)
                            DispatchQueue.main.async {
                                self.passedIn.text = ("Phrase: \(self.thePhrase.text!)")
                                self.resulsLabel.text = ("Translation: \(translatedText)")
                                self.thePhrase.text = ""
                            }
    
                        }
                    } catch {
                        print(error)
                    }
                })
                // execute the task and then wait for the response
                // to run the completion handler. This is async!
                task.resume()
                
            } else {
                print("Please write a valid word")
            }
        }

////////////
//records when button is green
///////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recordAndRecognizeSpeech() {
                guard let node = audioEngine.inputNode else { return }
                let recordingFormat = node.outputFormat(forBus: 0)
                node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
                    buffer, _ in self.request.append(buffer)
                }
        
                audioEngine.prepare()
                do {
                    try  audioEngine.start()
                    print("It Started")
        
                } catch {
                    return print(error)
                }
        
                guard let myRecognizer = SFSpeechRecognizer() else {
                    print("damn")
                    return
                }
                if !myRecognizer.isAvailable {
                    print("nope")
                    return
                }
        
                recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {
                    result, error in
                    if let result = result {
                        print("in task")
                        let bestString = result.bestTranscription.formattedString
                        self.thePhrase.text = bestString
                        print("wtf")
                    } else if let error = error {
                        print(error)
                        print("the errors")
                    }
                })
                print("It stopped")
                
            }
}
