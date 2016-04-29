//
//  NetworkController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/28/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

// This whole file will be re-built in the new app by Stephen, "toUploadDicitonary will be the current users info" not this static data

// Save token to local persistance and have if statement for when token expires in 7 days for another request to be made

/*
 
 This is the json data Serialized: Optional({
 AccessToken = C27244B34741D47C56F53688A629B41784F5D35960AC9283E4EDB05FD0F8FB4562865F6D2AECD72B750DDCA6919BCD2CBD10E56418AC6F281B9DB1843E7FBCFED905BF0D3F5853BBF60E2F571D1DBC6F12676745AD60F71D90CC0F3CC1BB216D68F9BF4650F27689B7BB90141C332B45;
 Active = "<null>";
 Authenticated = Authenticated;
 ExpirationDate = "2016-05-05T13:55:23.6205892-06:00";
 })
 
 */


class NetworkController {
    
    static let telenotesBaseURL = "http://api.telenotes.com/api/login/TN_AuthenticateUser"

    static let toUploadDictionary = ["MailBox" : 9246, "Password" : "Telenotes", "AuthCode" : "6AD90A48-B038-415A-8957-4F9848FCC8DD", "SyncDeviceName" : "Droid"]
    
    static func uploadAuthData(completion:(json:[String:AnyObject])->Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: telenotesBaseURL)!)
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
                    if let json = json {
                        print("non optional json data: \(json)")
                    }
                    print("This is the json data Serialized: \(json)")
                } catch let error as NSError {
                    print("This is the Error: \(error.localizedDescription)")
                }
            }
            print("This is the dataTask error: \(error?.localizedDescription)")
        }
        dataTask.resume()
    }
    
    static let azureBaseURL = "api.telenotes.com/api/AzureSecurity/AzureWritePermissions"
    
    // this will be saved in a key chain on new app
    static let headerFileAuthToken = "C27244B34741D47C56F53688A629B41784F5D35960AC9283E4EDB05FD0F8FB4562865F6D2AECD72B750DDCA6919BCD2CBD10E56418AC6F281B9DB1843E7FBCFED905BF0D3F5853BBF60E2F571D1DBC6F12676745AD60F71D90CC0F3CC1BB216D68F9BF4650F27689B7BB90141C332B45"
    
    // access token from telenotes is thrown on as a header, // Search - authorization header in http request

    func getCredentialsFromAzure(completion:(json:[String:AnyObject])->Void) {
        
        
        
        
    }
    
    
    
    
    
}



















