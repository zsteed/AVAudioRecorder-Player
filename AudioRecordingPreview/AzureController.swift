//
//  AzureController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/27/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

/*
 ▿ 8 elements
 ▿ [0] : 2 elements
 - .0 : QueueUri
 - .1 : https://telenotesmedia.queue.core.windows.net/transcription/messages
 
 ▿ [1] : 2 elements
 - .0 : QueueAccessSignature
 - .1 : ?sv=2015-07-08&si=mobileAgent9246QueueWriteAuth&sig=lqDgC%2BlOMxuhpbGFRAQTvYez1vjioL%2Fl8JTfJpgKohw%3D&se=2016-04-29T16%3A33%3A05Z&sp=a
 
 ▿ [2] : 2 elements
 - .0 : BlobUri
 - .1 : https://telenotesmedia.blob.core.windows.net/callnotes/
 
 ▿ [3] : 2 elements
 - .0 : ExpirationDate
 - .1 : 2016-04-29T10:03:05.7358339-06:00

 ▿ [5] : 2 elements
 - .0 : QueueName
 - .1 : transcribe
 
 ▿ [6] : 2 elements
 - .0 : BlobAccessSignature
 - .1 : ?sv=2015-07-08&sr=c&si=mobileAgent9246CallnoteWriteAuth&sig=2BNohd3pgYIrOKkbT3DWQ%2BgOzNChswWyBxXYvspkiBg%3D&se=2016-04-29T16%3A33%3A05Z&sp=w


 */

class AzureController {
    
    static let sharedInstance = AzureController()
    
    static let azureAccountName = "telenotesmedia"
    static let blobAudioContainerName = "callnotes"
    
    // Will be saved in Core Data, just hard coding for now
    
    static let blobAudioAccessSignature = "?sv=2015-07-08&sr=c&si=mobileAgent9246CallnoteWriteAuth&sig=2BNohd3pgYIrOKkbT3DWQ%2BgOzNChswWyBxXYvspkiBg%3D&se=2016-04-29T16%3A33%3A05Z&sp=w"
    
    
    static let blobAudioAzureURL = "https://telenotesmedia.blob.core.windows.net/callnotes" + AzureController.blobAudioAccessSignature
    
    
    static func uploadBlobToAzure(recordingURL:NSURL, blobName:String, completion:(success:Bool)->Void) {
        
        let myAccount = AZSCloudStorageAccount(fromConnectionString: azureAccountName)
        let blobClient = myAccount.getBlobClient()
        let blobContainer = blobClient.containerReferenceFromName(blobAudioContainerName)
        
        // container function below currently not allowing public access
        
        blobContainer.createContainerIfNotExistsWithAccessType(.Off, requestOptions: nil, operationContext: nil) { (error, exists) in
            if error != nil {
                print(error?.localizedDescription)
                completion(success: false)
            } else {
                let blockBlob = blobContainer.blockBlobReferenceFromName(blobName)
                blockBlob.uploadFromFileWithURL(recordingURL, completionHandler: { (error) in
                    if error != nil {
                        completion(success: false)
                        print(error?.localizedDescription)
                    } else {
                        completion(success: true)
                    }
                })
            }
        }
    }
    
    
    
    
    
    
    
    
    
}
