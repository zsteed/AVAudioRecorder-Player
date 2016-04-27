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
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var progressViewMeter: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var timer = NSTimer()
    var progressTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.backgroundColor = UIColor.blueColor()
        AudioController.sharedInstance.checkHeadphones()
        AudioController.sharedInstance.notificationCheck()
        
        stopButton.enabled = false
        pauseButton.enabled = false
        progressViewMeter.setProgress(0.0, animated: true)
        dispatch_async(dispatch_get_main_queue()) {
            AudioController.sharedInstance.listRecordings()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Methods
    
    func timeIntervalsForTimer(time:NSTimer) {
        if let recorder = AudioController.sharedInstance.recorder {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime % 60)
            let s = String(format: "%02d:%02d", min, sec)
            timeLabel.text = s
            recorder.updateMeters()
            let apc0 = recorder.averagePowerForChannel(0)
            let peak0 = recorder.peakPowerForChannel(0)
            dispatch_async(dispatch_get_main_queue(), {
                self.progressViewMeter.progress = self.adaptPowerForChannel(apc0)
            })
        }
    }
    
    func adaptPowerForChannel(rawValue:Float) ->Float {
        let maxPowerLevel = Float(40.0)
        let adaptedPowerLevel = (rawValue + maxPowerLevel) / maxPowerLevel
        return adaptedPowerLevel
    }
    
    
    
    // MARK: - Buttons Tapped
    
    
    @IBAction func pauseButtonTapped(sender: AnyObject) {
        if let recorder = AudioController.sharedInstance.recorder {
            if recorder.recording {
                recorder.pause()
                timer.invalidate()
                stopButton.enabled = true
                pauseButton.setTitle("Resume", forState: .Normal)
            } else {
                pauseButton.setTitle("Pause", forState: .Normal)
                AudioController.sharedInstance.setUpPermission(false)
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timeIntervalsForTimer(_:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    
    @IBAction func recordButtonTapped(sender: AnyObject) {
       AudioController.sharedInstance.record()
        recordButton.enabled = false
        stopButton.enabled = true
        pauseButton.enabled = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timeIntervalsForTimer(_:)), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func uploadButtonTapped(sender: AnyObject) {
        
    }

    @IBAction func stopButtonTapped(sender: AnyObject) {
        AudioController.sharedInstance.stop()
        recordButton.enabled = true
        stopButton.enabled = false
        pauseButton.enabled = false
        timer.invalidate()
        dispatch_async(dispatch_get_main_queue()) {
            AudioController.sharedInstance.listRecordings()
            self.progressViewMeter.progress = 0.0
            self.timeLabel.text = "00:00"
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        AudioController.sharedInstance.play(RecordingsController.sharedInstance.recordings[indexPath.row])
        
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RecordingCellTableViewCell {
            cell.setProgressIndicator()
        }
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











