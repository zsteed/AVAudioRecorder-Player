//
//  AzureController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/27/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

class AzureController {
    
    static let sharedInstance = AzureController()
    
    
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
    
    // MARK: - Add Blob With Shared Access Key
    
//    static let sharedAccessKey = "DefaultEndpointsProtocol=https;AccountName=telenotesmedia;AccountKey=V4nK9UCZY0Rq8iINKCikH/EbSC2yC6Ig3HyghmCEan6owx4aHqsnyQoBr7+FWaVzV6X52aCuWy685eZYIj2a9g=="
//    
//    static func addBlobWithAccessKeyTest(blobName:String, urlToAudio:NSURL, completion:(success:Bool, error:NSError?)->Void) {
//        
//        let storageAccount = AZSCloudStorageAccount(fromConnectionString: sharedAccessKey)
//        
//        let blobClient = storageAccount.getBlobClient()
//        
//        let container = blobClient.containerReferenceFromName("callnotes")
//        
//        let blob = container.blockBlobReferenceFromName(blobName)
//        
//        blob.uploadFromFileWithURL(urlToAudio) { (error) in
//            
//            if let error = error {
//                completion(success: false, error: error)
//                print(error)
//            } else {
//                completion(success: true, error: nil)
//            }
//        }
//    }
    
//    static func addMultipleBlobs(blobName:String, audioFiles:[NSURL]?, completion:(success:Bool)->Void) {
//        
//        let storageAccount = AZSCloudStorageAccount(fromConnectionString: sharedAccessKey)
//        
//        let blobClient = storageAccount.getBlobClient()
//        
//        let container = blobClient.containerReferenceFromName("callnotes")
//        
//        let blob = container.blockBlobReferenceFromName(blobName)
    
//        let myGroup = dispatch_group_create()
//        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        
//        var arr = [AZSBlockListItem]()
//        
//        if let audioFiles = audioFiles {
//            for item in audioFiles {
//                let encodeString = "\(item)"
//                let str = encodeString.dataUsingEncoding(NSUTF8StringEncoding)
//                let base64 = str?.base64EncodedDataWithOptions(.Encoding64CharacterLineLength)
//                let ite = AZSBlockListItem(blockID: "\(base64)", blockListMode: AZSBlockListMode(rawValue: 0)!)
//                arr.append(ite)
//                blob.uploadBlockListFromArray(arr, completionHandler: { (error) in
//                    print(error)
//                })
//
//            }
//        }
        

//        if let audioFiles = audioFiles {
//            dispatch_group_enter(myGroup)
//            for item in audioFiles {
//                dispatch_async(queue, {
//                    blob.uploadFromFileWithURL(item, completionHandler: { (error) in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            print("upload successfull")
//                        }
//                        dispatch_group_leave(myGroup)
//                    })
//                })
//            }
//            dispatch_group_notify(myGroup, queue, { 
//                print("finished notificaiton")
//            })
//        }
        
//        if let audioFiles = audioFiles {
//            for item in audioFiles {
//                dispatch_group_enter(myGroup)
//                dispatch_async(queue, { 
//                    let stream = NSInputStream(URL: item)
//                    blob.uploadFromStream(stream!, completionHandler: { (error) in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            print("upload successful")
//                        }
//                        
//                    })
//                })
//            }
//            dispatch_group_leave(myGroup)
//            dispatch_group_notify(myGroup, queue, { 
//                print("finished notifying")
//            })
//        }
//    }
    
    // url Sample https://myaccount.queue.core.windows.net/myqueue/messages?visibilitytimeout=<int-seconds>&messagettl=<int-seconds>

    static let queueURI = "https://telenotesmedia.queue.core.windows.net/transcription/messages"
    
    static let queueSASToken = "?sv=2015-07-08&si=mobileAgent9246QueueWriteAuth&sig=SCC9Zo%2BlGuXG%2F5ytTeJB7HkeGckwbMokgn6K8DUxhPo%3D&se=2016-05-02T19%3A27%3A45Z&sp=a"
    
    
    static let sharedKeyAccess2 = "fKWFJnBHNiA8p/geg4arXR5DGPVR6VClHGcdpyG6jUUvkPkahKQCjmQJVamaN6c0FoSxQhCPbMmZk7mOqGp8cA=="
    
    // MARK: - Add Queue Message To Azure
    
    static func addMessageToQueue(uploadMessage:[String:AnyObject], completion:(success:Bool)->Void) {

        let url = queueURI
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setValue("\(RecordingsController.sharedInstance.dateFormatForHTTP(NSDate()))", forHTTPHeaderField: "x-ms-date")
        request.setValue("SharedKey telenotesmedia:" + sharedKeyAccess2, forHTTPHeaderField: "Authorization")
        
        let re = "What up?"
        let data = re.dataUsingEncoding(NSUTF8StringEncoding)
        
//        do {
//            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(uploadMessage, options: [])
//        } catch {
//            print(error)
//        }
        
        let dataTask = session.uploadTaskWithRequest(request, fromData: data) { (data, response, erro) in
            print(erro)
        }
        
        dataTask.resume()
    }
    
    
    /*
     ▿ 8 elements
     ▿ [0] : 2 elements
     - .0 : ExpirationDate
     - .1 : 2016-05-04T14:39:59.568714Z
     ▿ [1] : 2 elements
     - .0 : QueueUri
     - .1 : https://telenotesmedia.queue.core.windows.net/transcription/messages
     ▿ [2] : 2 elements
     - .0 : QueueName
     - .1 : transcribe
     ▿ [3] : 2 elements
     - .0 : BlobAccessSignature
     - .1 : ?sv=2015-07-08&sr=c&sig=Yybz8oDY8Yk%2FPcPx6ytvxVSP3Hq65%2FF%2BSe2v2N3S8u4%3D&se=2016-05-04T14%3A39%3A59Z&sp=acw
     ▿ [4] : 2 elements
     - .0 : ContainerName
     - .1 : callnotes
     ▿ [5] : 2 elements
     - .0 : BlobUri
     - .1 : https://telenotesmedia.blob.core.windows.net/callnotes/
     ▿ [6] : 2 elements
     - .0 : QueueAccessSignature
     - .1 : ?sv=2015-07-08&sig=1wI9%2BQw%2FBVxK%2F3xqcU9tAjbnDIwYS%2BazVNQqzCGkouw%3D&se=2016-05-04T14%3A39%3A59Z&sp=au
     ▿ [7] : 2 elements
     - .0 : AccountName
     - .1 : telenotesmedia

    */
    
    
    
    
}
