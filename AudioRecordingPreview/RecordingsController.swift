//
//  RecordingsController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/25/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//
 
import UIKit

class RecordingsController {
  
  static let sharedInstance = RecordingsController()
  
  var recordings = [NSURL]()
  
  var myButton: Int = 0
  
  func readableDate(date:NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .FullStyle
    dateFormatter.timeStyle = .FullStyle
    let returnDate = dateFormatter.stringFromDate(date)
    return returnDate
  }
}
