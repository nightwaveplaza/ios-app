//
//  PlaybackService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import RxSwift
import RxCocoa

enum PlaybackQuality: Int {
    case High = 0
    case Eco = 1
}

class PlaybackService {
    
    var qualityStorage = CCUserDefaultsStorage(with: NSNumber.self, key: "quality")
    
    var quality: PlaybackQuality {
        set {
            qualityStorage?.save(NSNumber(integerLiteral: newValue.rawValue))
            self.replacePlayerForQuality()
        }
        get {
            if let storedQuality = qualityStorage?.getObject() as? NSNumber, let quality = PlaybackQuality.init(rawValue: storedQuality.intValue) {
                return quality;
            } else {
                return .High
            }
        }
    }
    
    var playbackRate$ = BehaviorSubject<Float>(value: 0)
    
    var player = AVPlayer(url: URL(string: "https://radio.plaza.one/mp3")!)
    
    init() {
        self.setupPlaybackSession()
        self.setupRemoteTransportControls()

        self.replacePlayerForQuality()        
    }
    
    func toggle() {
        
        if (player.rate == 1) {
            player.pause()
        } else {
            player.play()
        }
        self.playbackRate$.onNext(player.rate)
    }
    
    var paused: Bool {
        get {
            return self.player.timeControlStatus == AVPlayer.TimeControlStatus.paused
        }
    }
    
    func replacePlayerForQuality() {
        
        let url = self.quality == .High ? URL(string: "https://radio.plaza.one/mp3")! : URL(string: "https://radio.plaza.one/mp3_96")!
        
        let rate = self.player.rate;
        
        self.player.pause()
        
        self.player = AVPlayer(url: url)
        
        self.player.rate = rate
        
        
    }
    
    private func setupPlaybackSession() {
       
        let session = AVAudioSession.sharedInstance()
        
        do {
            if #available(iOS 13.0, *) {
                try session.setCategory(AVAudioSession.Category.playback,
                                        mode: .default,
                                        policy: .longFormAudio,
                                        options: [])
            } else {
                try session.setCategory(AVAudioSession.Category.playback, options: [])
            }
        } catch let error {
            fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
        do {
            try session.setActive(true)
        } catch let error {
            fatalError("Unable to active audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupRemoteTransportControls() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                self.playbackRate$.onNext(self.player.rate)
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                self.playbackRate$.onNext(self.player.rate)
                return .success
            }
            return .commandFailed
        }
    }
}
