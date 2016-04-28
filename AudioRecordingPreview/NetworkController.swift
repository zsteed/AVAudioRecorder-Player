//
//  NetworkController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/28/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

class NetworkController {
    
    static let base = "http://api.telenotes.com/api/login/TN_AuthenticateUser"

    static let toUploadDictionary = ["MailBox" : 9246, "Password" : "Telenotes", "AuthCode" : "6AD90A48-B038-415A-8957-4F9848FCC8DD", "SyncDeviceName" : "Droid"]
    
    static func uploadAuthData(completion:(json:[String:AnyObject])->Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: base)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(NetworkController.toUploadDictionary, options: [])
        } catch {
            print(error)
        }
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            if let data = data {
                do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    print("This is the json data Serialized: \(json)")
                } catch let error as NSError {
                    print("This is the Error: \(error.localizedDescription)")
                }
            }
            print("This is the dataTask error: \(error?.localizedDescription)")
        }
        dataTask.resume()
    }
    
}








