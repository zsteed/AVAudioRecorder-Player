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
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pauseButton.enabled = false
        progressView.setProgress(0.0, animated: true)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // Buttons Tapped Functions
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        AudioController.sharedInstance.setSessionPlayback()
        AudioController.sharedInstance.play()
        playButton.enabled = false
        pauseButton.enabled = true
    }

    
    @IBAction func pauseButtonTapped(sender: AnyObject) {
        AudioController.sharedInstance.pause()
        pauseButton.enabled = false
        playButton.enabled = true
    }

    
    // Call in Table View Data Source
    
    func updateCellWithData(indexPath:NSIndexPath) {
        RecordingsController.sharedInstance.recordings[indexPath.row].lastPathComponent
        self.recordingLabel.text = "\(RecordingsController.sharedInstance.readableDate(NSDate()))"
    }
    
    

}
