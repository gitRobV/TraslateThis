//
//  RecentTransTableViewController.swift
//  TranslateThis
//
//  Created by Robert on 7/18/17.
//  Copyright © 2017 Robert Villarreal. All rights reserved.
//

import UIKit
import AVFoundation

class RecentTransTableViewController: UITableViewController {
    
    var phrases = [NSDictionary] ()
    
    let synthesizer = AVSpeechSynthesizer()
    
    
    func getRequestSession(urlStr: String, completionHandler:@escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        let url = URL(string: urlStr)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!, completionHandler: completionHandler)
        
        task.resume()
    }
    
    
    func speak(string: String) {
        let rawText = string
        let utterance = AVSpeechUtterance(string: rawText)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        self.synthesizer.speak(utterance)
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let translations = "http://13.59.119.156/phrases/"
        
        getRequestSession(urlStr: translations, completionHandler: {
            data, response, error in
            do {
                if let requestResults = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                    print(requestResults)
                    for object in requestResults {
                        let phrase = object as! NSDictionary
                        
                        self.phrases.append(phrase)


                    }
                    
                }
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
            } catch {
                print(error)
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phrases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phraseCell", for: indexPath)
        
        let indexOffset = phrases.count - 1
        
        let newIndex = indexOffset - indexPath.row
        
        cell.textLabel?.text = phrases[newIndex]["phrase"] as? String
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.speak(string: phrases[indexPath.row]["translation"] as! String)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
