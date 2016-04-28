//
//  RecordingCellTableViewCell.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/25/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit

protocol CustomCellDelegate {
    func cellTapped(cell:RecordingCellTableViewCell)
}

class RecordingCellTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    var progress = NSProgress()
    var timer = NSTimer()
    var myTimer = NSTimer()
    var buttonDelegate: CustomCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //progressView.hidden = false
        progressView.setProgress(0.0, animated: false)
        playButton.setTitle("Play", forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setProgressIndicator() {
        progressView.setProgress(0.0, animated: false)
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateProgress(_:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        
        if let delegate = buttonDelegate {
            delegate.cellTapped(self)
        }
        
        let cellForRow = RecordingsController.sharedInstance.myButton
        
        if let player = AudioController.sharedInstance.player {
            if player.playing {
                player.pause()
                myTimer.invalidate()
                progressView.setProgress(Float(player.duration % 60), animated: false)
                playButton.setTitle("Play", forState: .Normal)
            } else {
                playButton.setTitle("Pause", forState: .Normal)
                AudioController.sharedInstance.play(RecordingsController.sharedInstance.recordings[cellForRow])
                setProgressIndicator()
            }
        } else {
            playButton.setTitle("Pause", forState: .Normal)
            AudioController.sharedInstance.play(RecordingsController.sharedInstance.recordings[cellForRow])
            setProgressIndicator()
        }
    }
    
    func updateProgress(timer:NSTimer) {
        if let player = AudioController.sharedInstance.player {
            if progressView.progress < Float(player.duration % 60) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressView.setProgress(Float(player.duration % 60), animated: true)
                })
            }
        }
    }

    
    // Call in Table View 
    
    func updateCellWithData(indexPath:NSIndexPath) {
        RecordingsController.sharedInstance.recordings[indexPath.row].lastPathComponent
        self.recordingLabel.text = "\(RecordingsController.sharedInstance.readableDate(NSDate()))"
        
    }
    
    
    
    
    
    

}
