//
//  SecurityController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/28/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit
import Security

let kSecclassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)


class SecurityController: NSObject {
    
    func setPasscode(identifier:String, passcode:String) {
        
        let dataFromString:NSData = passcode.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let keyChainQuery = NSDictionary(objects: [kSecclassGenericPasswordValue, identifier, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecValueDataValue])
        
        SecItemDelete(keyChainQuery as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(keyChainQuery as CFDictionaryRef, nil)
        
    }
    
    
    func getPasscode(identifier:String) -> NSString? {
        
        let keychainQuery = NSDictionary(objects: [kSecclassGenericPasswordValue, identifier, kCFBooleanTrue, kSecMatchLimitOneValue],
                                         forKeys: [kSecClassValue, kSecAttrServiceValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var passcode: NSString?
        
        if status == errSecSuccess {
            let retrievedData: NSData? = dataTypeRef as? NSData
            if let result = NSString(data: retrievedData!, encoding: NSUTF8StringEncoding) {
                passcode = result as String
            }
        } else {
            print("Nothing retrieved from keychain, status code \(status)")
        }
        return passcode
        
    }

    
}
