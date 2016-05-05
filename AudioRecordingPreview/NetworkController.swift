//
//  NetworkController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/28/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

class NetworkController {
    
    static let telenotesBaseURL = "http://api.telenotes.com/api/login/TN_AuthenticateUser"

    // Sample Data For Testing Purposes
    static let toUploadDictionary = ["MailBox" : 9246, "Password" : "Telenotes", "AuthCode" : "6AD90A48-B038-415A-8957-4F9848FCC8DD", "SyncDeviceName" : "Droid"]
    
    
    // Retrives Access Token from Telenotes server, lasts 7 days then another will need to be requested
    static func uploadAuthData(uploadDictionary:[String:AnyObject], url:String, completion:(json:[String:AnyObject])->Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(uploadDictionary, options: [])
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
    
    static let azureBaseURL = "http://api.telenotes.com/api/AzureSecurity/GetAzureWritePermission"
    
    // this will be saved in a key chain on new app
    // Current Auth Token From Telenotes server
    static let headerFileAuthToken = "C27244B34741D47C56F53688A629B41784F5D35960AC9283E4EDB05FD0F8FB4562865F6D2AECD72B750DDCA6919BCD2CBD10E56418AC6F281B9DB1843E7FBCFED905BF0D3F5853BBF60E2F571D1DBC6F12676745AD60F71D90CC0F3CC1BB216D68F9BF4650F27689B7BB90141C332B45"
    
    // retrives SAS from Azure to start uploading Blobs / Queue Messages
    
    static func getCredentialsFromAzure(headerFile:String, url:String, completion:(json:[String:AnyObject])->Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "GET"

        request.setValue(headerFile, forHTTPHeaderField: "Authorization")
        
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, erro) in
            if let data = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
                    if let json = json {
                        print("Json Data at azure: \(json)")
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
    
    
    
    // Will be saved in Core Data, just hard coding for now
    static let blobAudioAccessSignature = "?sv=2015-07-08&sr=c&sig=Yybz8oDY8Yk%2FPcPx6ytvxVSP3Hq65%2FF%2BSe2v2N3S8u4%3D&se=2016-05-04T14%3A39%3A59Z&sp=acw"
    
    static let blobAudioAzureURL = "https://telenotesmedia.blob.core.windows.net/callnotes"
    
    // MARK: - Add Blob With SAS
    
    static func addBlob(blobName:String, audioFile:NSURL, completion:(success:Bool, error:NSError?)->Void) {
        
        let newURL = blobAudioAzureURL + blobAudioAccessSignature
        
        let container = AZSCloudBlobContainer(url: NSURL(string: newURL)!)
        
        let blockBlob = container.blockBlobReferenceFromName(blobName)
        
        blockBlob.uploadFromFileWithURL(audioFile) { (error) in
            
            if let error = error {
                completion(success: false, error: error)
            } else {
                completion(success: true, error: nil)
            }
        }
    }
    
    
    //MARK: - Adding Messages To Azure Queue
    
    static let queueURI = "https://telenotesmedia.queue.core.windows.net/transcription/messages"
    
    static let queueSASToken = "?sv=2015-07-08&sig=yHp3EvBELcB%2B6%2FRiIF3wOtfgQChpxRZLCy%2FfzhaZVu0%3D&se=2016-05-05T17%3A03%3A41Z&sp=au"
    
    // MARK: - Add Queue Message To Azure
    
    static func addMessageToQueue(uploadMessage:[String:AnyObject], completion:(success:Bool)->Void) {
        
        let url = queueURI + queueSASToken
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //        do {
        //        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(uploadMessage, options: .PrettyPrinted)
        //        } catch let erro as NSError {
        //            print(erro)
        //        }
        
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("gzip,deflate", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        
        request.setValue("\(RecordingsController.sharedInstance.dateFormatForHTTP(NSDate()))", forHTTPHeaderField: "x-ms-date")
        
        let bodyData = "<QueueMessage><MessageText>is it working?</MessageText></QueueMessage>"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            
            print(error)
        }
        dataTask.resume()
    }
    /*
     Queue Format:
     
     <QueueMessage>
     <MessageText>{ordernumber: 7897075698, ordercontent:["hamburger", "fries", "soda"]}</MessageText>
     </QueueMessage>
     
     Date Formats:
     
     Wed, May 04, 2016, 17:32:56 +0000
     Wed, 04 May 2016 17:15:21 GMT
     */

}



















