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

class PlaybackService {
    
    
    let player = AVPlayer(url: URL(string: "https://radio.plaza.one/mp3")!)
    
    init() {
        self.setupPlaybackSession()
        self.setupRemoteTransportControls()
    }
    
    func toggle() {
        if (player.rate == 1) {
            player.pause()
        } else {
            player.play()
        }
    }
    
    var paused: Bool {
        get {
            return self.player.timeControlStatus == AVPlayer.TimeControlStatus.paused
        }
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
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
}
