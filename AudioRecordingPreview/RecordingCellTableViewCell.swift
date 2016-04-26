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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.hidden = true        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateProgress(indexPath:NSIndexPath) {
        
        progressView.setProgress(0.0, animated: true)
        
        progressView.hidden = false

        if let player = AudioController.sharedInstance.player {
            if progressView.progress < 1.0 {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if player.playing {
                        
                    }
                    let progressUserInfo = [NSProgressFileOperationKindKey:NSProgressFileOperationKindReceiving]
                    
                    let progress = NSProgress(parent: nil, userInfo: progressUserInfo)
                    
                    progress.kind = NSProgressKindFile
                    
                    progress.totalUnitCount = RecordingsController.sharedInstance.recordings[indexPath.row]

                    progress.completedUnitCount = 0
                    
                    progress.addObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>, options: <#T##NSKeyValueObservingOptions#>, context: <#T##UnsafeMutablePointer<Void>#>)
                    
                    
                    
                    self.progressView.observedProgress = progress
                })
            }
            
            if progressView.progress == 1.0 {
                progressView.hidden = true
            }
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
