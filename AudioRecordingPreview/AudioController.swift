//
//  AudioController.swift
//  AudioRecordingPreview
//
//  Created by Zachary Steed on 4/25/16.
//  Copyright © 2016 Zachary Steed. All rights reserved.
//

import UIKit
import AVFoundation

// TODO: - check that I'm using, m4a for recording / sending files

// TODO: - Check that I'm using settings on recorder dictionary / keys correctly

class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    // MARK: - Properties
    
    var meterTimer: NSTimer?
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    var soundFile: NSURL?
    var labelString: String?
    var timeDisplaly: UILabel?
    
    static let sharedInstance = AudioController()
    
    // MARK: - View did load methods
    
    func setSessionPlayback() {
        let session = AVAudioSession.sharedInstance()
        
        do  {
            try session.setCategory(AVAudioSessionCategoryRecord)
        } catch let error as NSError {
            print("Error on line \(#line) for set category error \(error.localizedDescription)")
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Error on line \(#line) for set active error \(error.localizedDescription)")
        }
    }

    
    // MARK: - Set up / Helper Methods
    
    func updateAudioMeter(timer:NSTimer) {
        if let recorder = recorder {
            if recorder.recording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime % 60)
                timeDisplaly?.text = String(format: "%02d:%02d", min, sec)
                recorder.updateMeters()
            }
        }
    }
    

    
    func setUpPermission(setUp:Bool) {
        let session = AVAudioSession.sharedInstance()
        if session.respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:))) {
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    self.setSessionPlayAndRecord()
                    if setUp {
                        self.setUpRecorder()
                    }
                    if let recorder = self.recorder {
                        recorder.record()
                        self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateAudioMeter(_:)), userInfo: nil, repeats: true)
                    }
                } else {
                    print("User denied Permission")
                }
            })
        }
    }
    
    
    func setUpRecorder() {
        let fileName = "Recording - \(RecordingsController.sharedInstance.readableDate(NSDate())).m4a"
        
        let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        self.soundFile = documentDirectory.URLByAppendingPathComponent(fileName)
        
        let settings = [AVFormatIDKey:NSNumber(unsignedInt : UInt32(kAudioFormatAppleLossless)),
                        AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
                        AVEncoderBitRateKey : 320000,
                        AVNumberOfChannelsKey: 2,
                        AVSampleRateKey : 44100.0]
        do {
            if let soundFile = soundFile {
                recorder = try AVAudioRecorder(URL: soundFile, settings: settings)
                if let recorder = recorder {
                    recorder.delegate = self
                    recorder.meteringEnabled = true
                    recorder.prepareToRecord()
                }
            }
        } catch let error as NSError {
            print("Error on line - \(#line) \(error.localizedDescription)")
        }
    }
    
  
    
    
    func listRecordings() {
        let documentsdirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        do {
            let urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsdirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            RecordingsController.sharedInstance.recordings = urls.filter({ (name:NSURL) -> Bool in
                return name.lastPathComponent!.hasSuffix("m4a")
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        
        do  {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("Error on line \(#line) for set category error \(error.localizedDescription)")
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Error on line \(#line) for set active error \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Button Tapped Methods To Implement
    
    func record() {
        
        if player != nil && player!.playing {
            player!.stop()
        }
        
        if recorder == nil {
            print("Recording. Recorder == nil, on line \(#line) of function \(#function)")
            self.setUpPermission(true)
        } else {
            self.setUpPermission(false)
        }
        
//        if recorder != nil && recorder!.recording {
//            print("Pausing on line \(#line) of function \(#function)")
//            recorder!.pause()
//        } else {
//            print("Recording on line \(#line) of function \(#function)")
//            self.recordWithPermission(false)
//        }
    }
    
    func stop() {
        if let recorder = recorder {
            recorder.stop()
        }
        
        if let meterTimer = meterTimer {
            meterTimer.invalidate()
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func pause() {
        if let player = player {
            player.pause()
        }
    }
    
    func play() {
        var url:NSURL?
        if self.recorder != nil {
            url = self.recorder!.url
        } else {
            url = self.soundFile!
        }
        print("Playing URL on line \(#line) of function \(#function)")
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url!)
            if let player = player {
                player.delegate = self
                player.prepareToPlay()
                player.volume = 1.0
                player.play()
            }
        } catch let error as NSError {
            self.player = nil
            print("Error - \(#line)\(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Audio Player Delegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("Finished playing audio")
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            print("Error with player delegate \(#line) for error \(error.localizedDescription)")
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