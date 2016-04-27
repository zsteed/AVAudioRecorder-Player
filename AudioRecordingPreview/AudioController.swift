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
    var timeDisplay: UILabel?
    
    static let sharedInstance = AudioController()
    
    // MARK: - View did load methods
    
    func checkHeadphones() {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        print(currentRoute)
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    
    func routeChange(notification:NSNotification) {
        print("routeChange \(notification.userInfo)")
        
        if let userInfo = notification.userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.NewDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.OldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.CategoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.Override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.WakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.Unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.NoSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.RouteConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func notificationCheck() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AudioController.routeChange(_:)), name:AVAudioSessionRouteChangeNotification, object:nil)
    }

    
    // MARK: - Set up / Helper Methods
    
    func updateAudioMeter(timer:NSTimer) {
        if let recorder = recorder {
            if recorder.recording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime % 60)
                let s = String(format: "%02d:%02d", min, sec)
                timeDisplay?.text = s
                recorder.updateMeters()
//                let apc0 = recorder.averagePowerForChannel(0)
//                let peak0 = recorder.peakPowerForChannel(0)
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
                    recorder.prepareToRecord()
                    recorder.meteringEnabled = true
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
        self.setUpPermission(true)

//        if recorder == nil {
//            print("Recording. Recorder == nil, on line \(#line) of function \(#function)")
//            self.setUpPermission(true)
//        } else {
//            self.setUpPermission(true)
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
    
    func play(url:NSURL) {
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
            if let player = player {
                player.delegate = self
                player.prepareToPlay()
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
