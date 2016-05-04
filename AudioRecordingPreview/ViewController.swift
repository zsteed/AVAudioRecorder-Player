//
//  ViewController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/21/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomCellDelegate, AVAudioRecorderDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var progressViewMeter: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    var timer = NSTimer()
    var progressTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Returns Credentials to speak to Azure, token lasts 7 days
//        NetworkController.uploadAuthData(NetworkController.toUploadDictionary, url: NetworkController.telenotesBaseURL) { (json) in
//            
//        }
        
        // MARK: - Returns SAS and Azure Details
        
//        NetworkController.getCredentialsFromAzure(NetworkController.headerFileAuthToken, url: NetworkController.azureBaseURL) { (json) in
//            
//        }

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
            let _ = recorder.peakPowerForChannel(0) // add to meter view 
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
        AudioController.sharedInstance.recorder?.delegate = self
        recordButton.enabled = false
        stopButton.enabled = true
        pauseButton.enabled = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timeIntervalsForTimer(_:)), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func uploadButtonTapped(sender: AnyObject) {
        if checked == true {
            
            let cellForRow = RecordingsController.sharedInstance.myButton
            let recording = RecordingsController.sharedInstance.recordings
            
            AzureController.addBlob("\(NSUUID().UUIDString)" + "\(1)", audioFile: recording[cellForRow], completion: { (success, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.uploadButton.setTitle("Uploading Audio. . .", forState: .Normal)
                    if success {
                        self.uploadButton.setTitle("Upload Audio", forState: .Normal)
                        let alert = UIAlertController(title: "File Uploaded Successfully", message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.uploadButton.setTitle("Upload Audio", forState: .Normal)
                        let alert = UIAlertController(title: "File Failed To Upload", message: "\(error?.localizedDescription)", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: "Please tap a recording to upload", message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }

    @IBAction func stopButtonTapped(sender: AnyObject) {
        AudioController.sharedInstance.stop()
        recordButton.enabled = true
        stopButton.enabled = false
        pauseButton.enabled = false
        pauseButton.setTitle("Pause", forState: .Normal)
        timer.invalidate()
        dispatch_async(dispatch_get_main_queue()) {
            AudioController.sharedInstance.listRecordings()
            self.progressViewMeter.progress = 0.0
            self.timeLabel.text = "00:00"
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Button Tapped Protocol / Delegate
    
    func cellTapped(cell: RecordingCellTableViewCell) {
        
        let indexPathForRow = self.tableView.indexPathForCell(cell)?.row
        if let indexPathForRow = indexPathForRow {
            RecordingsController.sharedInstance.myButton = indexPathForRow
        }
    }
    
    
    //MARK: - Table View Data Source
    
    var checked = false
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecordingsController.sharedInstance.recordings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("recorderCell", forIndexPath: indexPath) as? RecordingCellTableViewCell {
            
            cell.updateCellWithData(indexPath)
            
            if cell.buttonDelegate == nil {
                cell.buttonDelegate = self
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if checked == true {
                print("\(RecordingsController.sharedInstance.myButton)")
                checked = false
                cell.accessoryType = .None
            } else {
                print("\(RecordingsController.sharedInstance.myButton)")

                checked = true
                cell.accessoryType = .Checkmark
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            checked = false
            cell.accessoryType = .None
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
    
    
    
    // MARK: - Audio Recorder Delegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Finished Recording Audio")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        if let error = error {
            print("Error with recorder delegate \(#line) for error \(error.localizedDescription)")
        }
    }
    
}











