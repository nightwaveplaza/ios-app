//
//  SleepTimerService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 07.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation


class SleepTimerService {
    
    var playback: PlaybackService
    
    var timer: Timer?
    
    var onSleep: (() -> Void)?
    
    init(playback: PlaybackService) {
        self.playback = playback
    }
    
    
    func sleepAfter(minutes: Double) {
        let seconds = minutes * 60
        print("Will sleep in seconds \(seconds)")

        if seconds == 0 {
            self.timer?.invalidate()
            self.timer = nil
        } else {
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { (timer) in
                self.playback.player.pause()
                self.onSleep?()
            }
        }
        
    }
    
    func secondsToSleep() -> Double {
        if let timer = self.timer {
            print("Fire Interval, \(timer.fireDate.timeIntervalSinceNow)")
            return timer.fireDate.timeIntervalSince1970 * 1000
        } else {
            return 0
        }
    }
    
}
