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

    // TODO: - Use Unique ID for blob reference name // account ID + NSDate()
    
    // If using a SAS token, fill it in here.  If using Shared Key access, comment out the following line.
    let containerURL = "https://myaccount.blob.core.windows.net/mysampleioscontainer?sv=2015-02-21&st=2009-01-01&se=2100-01-01&sr=c&sp=rwdl&sig=mylongsig="
    var usingSAS = true
    
    
    // Shared Key / Only Use For Testing Purposes

    // If using Shared Key access, fill in your credentials here and un-comment the "UsingSAS" line:
    var connectionString = "DefaultEndpointsProtocol=https;AccountName=myaccount;AccountKey=myAccountKey=="
    var containerName = "sampleioscontainer"
    //var usingSAS = false
    
    
    func uploadBlobToAzure(recordingURL:NSURL, blobName:String) {
        
        let myAccount = AZSCloudStorageAccount(fromConnectionString: connectionString)
        let blobClient = myAccount.getBlobClient()
        let blobContainer = blobClient.containerReferenceFromName("blobContainer")
        
        // container function below currently not allowing public access
        
        blobContainer.createContainerIfNotExistsWithAccessType(.Off, requestOptions: nil, operationContext: nil) { (error, exists) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let blockBlob = blobContainer.blockBlobReferenceFromName(blobName)
                blockBlob.uploadFromFileWithURL(recordingURL, completionHandler: { (error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                
                    }
                })
            }
        }
    }
    
    
    
    
    
    
    
    
    
}
