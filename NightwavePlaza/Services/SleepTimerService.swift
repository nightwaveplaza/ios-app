//
//  SleepTimerService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 07.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SleepTimerService {
    
    var playback: PlaybackService
    
    var timer: Timer?
    
    var onSleep: (() -> Void)?
    
    let disposeBag = DisposeBag()
    
    init(playback: PlaybackService) {
        self.playback = playback
        
        self.playback.playbackRate$.subscribe(onNext: { [unowned self] rate in
            if rate == 0 {
                self.cleanupTimer()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: self.disposeBag)
    }
    
    
    func sleepAfter(minutes: Double) {
        let seconds = minutes * 60

        if minutes == 0 {
            self.cleanupTimer()
        } else {
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { (timer) in
                self.cleanupTimer()
                self.playback.player.pause()
                self.onSleep?()
            }
        }
        
    }
    
    func milisecondsSince1970ToSleep() -> Double {
        if let timer = self.timer {
            return timer.fireDate.timeIntervalSince1970 * 1000
        } else {
            return 0
        }
    }
    
    private func cleanupTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}
