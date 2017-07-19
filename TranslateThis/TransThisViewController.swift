//
//  TransThisViewController.swift
//  TranslateThis
//
//  Created by Robert on 7/18/17.
//  Copyright © 2017 Robert Villarreal. All rights reserved.
//

import UIKit
import AVFoundation

class TransThisViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var username: String?

    var translatedText: String?
    
    let synthesizer = AVSpeechSynthesizer()
    
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var phraseInput: UITextField!
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func translateButtonPressed(_ sender: UIButton) {
        
        let process = "Translating your phrase now."
        
        
        if let toBeTranaslated = phraseInput.text {
            
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
                        self.translatedText = translationDict["translatedText"] as? String

                        DispatchQueue.main.async {
                            self.resultsLabel.text = self.translatedText
                        self.speak(string: self.translatedText!)
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
        DispatchQueue.main.async {
            self.speak(string: process)
        }
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
    
        let newPhrase = phraseInput.text
        let newTrans = self.translatedText
        let user = username!
        
        var user_id: Int?
        
        
        let userAPI = "http://13.59.119.156/users/"
        
        getRequestSession(urlStr: userAPI, completionHandler: {
            data, response, error in
            
            do {
                if let requestResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                    
                    var userExists = false
                    
                    for object in requestResults {
                        let currUsers = object as! NSDictionary
                        if currUsers["username"] as? String == user {
                            if let newUser = currUsers["id"] {
                                user_id = newUser as? Int
                            }
                            userExists = true
                            break
                            
                        }
                    }
                    
                    if userExists == true {
                        let phraseAPI = "http://13.59.119.156/phrases/"
                        
                        self.postPhraseRequestSession(urlStr: phraseAPI, user_id: user_id!, newPhrase: newPhrase!, newTrans: newTrans!, completionHandler: {
                            data, response, error in
                            print(data!)
                            do {
                                
                                if let requestResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                                    print(requestResults)
                                }
                            } catch {
                                print(error)
                            }
                            
                            
                        })
                    } else {
                        
                        self.postRequestSession(urlStr: userAPI, username: user, completionHandler: {
                            data, respones, error in
                            
                            do {
                                if let userData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                    if let newUser = userData["id"] {
                                        user_id = newUser as? Int
                                    }
                                    
                                    let phraseAPI = "http://13.59.119.156/phrases/"
                                    
                                    self.postPhraseRequestSession(urlStr: phraseAPI, user_id: user_id!, newPhrase: newPhrase!, newTrans: newTrans!, completionHandler: {
                                        data, resones, error in
                                        
                                        do {
                                            
                                            if let requestResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                                                print(requestResults)
                                            }
                                        } catch {
                                            print(error)
                                        }
                                        
                                        
                                    })
                                    
                                    
                                    
                                }
                                
                                
                                
                            } catch {
                                print(error)
                            }
                            
                        })
                        
                        
                        
                        
                    }
                    
                    
                }
                
            } catch { print(error) }
            
        })
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        
        
        
    }
    
    
    
    func getRequestSession(urlStr: String, completionHandler:@escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        let url = URL(string: urlStr)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!, completionHandler: completionHandler)
        
        task.resume()
    }
    
    
    func postPhraseRequestSession(urlStr: String, user_id: Int, newPhrase: String, newTrans: String,  completionHandler:@escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)  {
        if let url = URL(string: urlStr){
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let bodyData = "user=\(user_id)&phrase=\(newPhrase)&translation=\(newTrans)"
            request.httpBody = bodyData.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)
            task.resume()
        }
    }
    
    
    func postRequestSession(urlStr: String, username: String, completionHandler:@escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)  {
        if let url = URL(string: urlStr){
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let bodyData = "username=\(username)"
            request.httpBody = bodyData.data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)
            task.resume()
        }
    }
    
    func speak(string: String) {
        let rawText = string
        let utterance = AVSpeechUtterance(string: rawText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synthesizer.speak(utterance)
        
    }
    
    var languages = ["Red", "White", "Blue"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = username {
            let greeting = "\(String(describing: user)), What would you like to translate"
            userLabel.text = greeting
            self.speak(string: greeting)
        }
        
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row] as String

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
