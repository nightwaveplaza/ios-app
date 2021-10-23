//
//  UpdateScheduler.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import RxSwift

class UpdateScheduler: NSObject {
       
    var tick = BehaviorSubject<Void>(value: ())
    
    var paused = false
    
    private var currentTimers: [Timer] = []
    
    func schedule(status: Status) {
        
        for timer in currentTimers {
            timer.invalidate()
        }
        currentTimers = []
        
        let fireDateDeltas = [-2, 0, 2, 4];
        var fireDates: [Date] = [];
        for delta in fireDateDeltas {
            fireDates.append(status.estimatedFinish().addingTimeInterval(Double(delta)))
        }
        
        for date in fireDates {
            let timer = Timer.scheduledTimer(withTimeInterval: date.timeIntervalSinceNow, repeats: false) { [unowned self] (timer) in
                self.fireTimer(timer: timer, context: [ "type": "end-track" ])
            }
            currentTimers.append(timer)
        }
        
    }
    
    func fireTimer(timer: Timer, context: [String: String]?) {
      
        if paused {
            return
        }
        
        self.tick.onNext(())
    }
    
    
}
