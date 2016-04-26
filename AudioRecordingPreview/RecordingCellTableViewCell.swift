//
//  RecordingCellTableViewCell.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/25/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

class RecordingCellTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var progress = NSProgress()
    var timer = NSTimer()
    var myTimer = NSTimer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.hidden = false
        progressView.setProgress(0.0, animated: false)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setProgressIndicator() {
        progressView.setProgress(0.0, animated: false)
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateProgress(_:)), userInfo: nil, repeats: true)
    }
    
    
    func updateProgress(timer:NSTimer) {
        if let player = AudioController.sharedInstance.player {

        if progressView.progress < Float(player.duration % 60) {
            
            dispatch_async(dispatch_get_main_queue(), {
                    self.progressView.setProgress(Float(player.duration % 60), animated: true)
                
            })
        }
        
//        if progressView.progress == 1.0 {
//            progressView.hidden = true
//        }
        }
    }
    
//    func timeIntervalsForTimer(time:NSTimer) {
//        if let player = AudioController.sharedInstance.player {
//            if player.playing {
//                progressView.progress = Float(player.duration)
//                player.duration
//            } else {
//                progressView.setProgress(0.0, animated: true)
//            }
//            
//            self.progressView.progress = 0.1
//            
//            if progressView.progress == 1.0 {
//                
//            }
//        }
//    }
    

    
    // Call in Table View Data Source
    
    func updateCellWithData(indexPath:NSIndexPath) {
        RecordingsController.sharedInstance.recordings[indexPath.row].lastPathComponent
        self.recordingLabel.text = "\(RecordingsController.sharedInstance.readableDate(NSDate()))"
        
    }
    
    
 
    
    
    
    

}
