//
//  RecordingCellTableViewCell.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/25/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit
import AVFoundation

protocol CustomCellDelegate: class {
  func cellTapped(cell:RecordingCellTableViewCell)
}

class RecordingCellTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
  
  // MARK: - Outlets
  
  @IBOutlet weak var recordingLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var playButton: UIButton!
  
  // MARK: - Properties
  
  var progress = NSProgress()
  var timer = NSTimer()
  weak var buttonDelegate: CustomCellDelegate?
  var paused = false
  
  //MARK: - System Functions
  
  override func awakeFromNib() {
    super.awakeFromNib()
    progressView.setProgress(0.0, animated: false)
    playButton.setTitle("Play", forState: .Normal)
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  // Progress Methods
  
  func setProgressIndicator() {
    progressView.setProgress(0.0, animated: true)
    timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateProgress(_:)), userInfo: nil, repeats: true)
  }
  
  func updateProgress(timer:NSTimer) {
    if let player = AudioController.sharedInstance.player {
      if progressView.progress < Float(player.duration % 60) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
          self?.progressView.setProgress(Float(player.duration % 60), animated: true)
        }
      }
    }
  }
  
  //MARK: - Button Tapped Functions
  
  @IBAction func playButtonTapped(sender: AnyObject) {
    
    if let delegate = buttonDelegate {
      delegate.cellTapped(self)
    }
    
    let cellForRow = RecordingsController.sharedInstance.myButton
    
    if let player = AudioController.sharedInstance.player {
      if player.playing {
        player.stop()
        timer.invalidate()
        playButton.setTitle("Play", forState: .Normal)
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
          self?.progressView.progress = 0.0
        }
      }  else {
        playButton.setTitle("Stop", forState: .Normal)
        AudioController.sharedInstance.play(RecordingsController.sharedInstance.recordings[cellForRow])
        player.delegate = self
        setProgressIndicator()
      }
    } else {
      playButton.setTitle("Stop", forState: .Normal)
      AudioController.sharedInstance.play(RecordingsController.sharedInstance.recordings[cellForRow])
      AudioController.sharedInstance.player?.delegate = self
      setProgressIndicator()
    }
  }
  
  // Call in Table View
  
  func updateCellWithData(indexPath:NSIndexPath) {
    RecordingsController.sharedInstance.recordings[indexPath.row].lastPathComponent
    self.recordingLabel.text = "My Date: " + "\(indexPath.row + 1)"
    
  }
  
  // MARK: - Audio Player Delegate
  
  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    playButton.setTitle("Play", forState: .Normal)
    print("Finished playing audio")
  }
  
  func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    if let error = error {
      print("Error with player delegate \(#line) for error \(error.localizedDescription)")
    }
  }
}




