//
//  ViewController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/21/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var progressViewMeter: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.setSessionPlayback()
        stopButton.enabled = false
        dispatch_async(dispatch_get_main_queue()) { 
            AudioController.sharedInstance.listRecordings()
            self.tableView.reloadData()
        }
    }
    
    
    
    // MARK: - Buttons Tapped
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
       AudioController.sharedInstance.record()
        recordButton.enabled = false
        stopButton.enabled = true
    }
    
    

    @IBAction func stopButtonTapped(sender: AnyObject) {
        AudioController.sharedInstance.stop()
        recordButton.enabled = true
        stopButton.enabled = false
        dispatch_async(dispatch_get_main_queue()) {
            AudioController.sharedInstance.listRecordings()
            self.tableView.reloadData()
        }
    }
    
    
    
    //MARK: - Table View Data Source
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecordingsController.sharedInstance.recordings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("recorderCell", forIndexPath: indexPath) as! RecordingCellTableViewCell
        
        cell.updateCellWithData(indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let fileManager = NSFileManager.defaultManager()
            
            do {
                try fileManager.removeItemAtURL(RecordingsController.sharedInstance.recordings[indexPath.row])
            } catch let error as NSError {
                print("Error with removing item on table view\(error.localizedDescription)")
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                AudioController.sharedInstance.listRecordings()
                tableView.reloadData()
                tableView.deleteRowsAtIndexPaths([], withRowAnimation: .Fade)
            })
        }
    }
}











