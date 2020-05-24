//
//  Status.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation


class Status: NSObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case maintenance
        case listeners
        case updatedAt
        case playback
    }
    
    var maintenance: Bool
    var listeners: Int
    var updatedAt: TimeInterval
    var playback: StatusPlayback
    
    var receivedAt = Date()
    var image: UIImage?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let anotherStatus = object as? Status  {
            return self.isEqual(toStatus: anotherStatus)
        } else {
            return false
        }
    }
    
    func isEqual(toStatus: Status) -> Bool {
        return toStatus.playback.songId == self.playback.songId
    }
    
    func estimatedFinish() -> Date {
        let startTime = self.receivedAt.addingTimeInterval(-Double(self.playback.position))
        return startTime.addingTimeInterval(Double(self.playback.length))
    }
    
    /**
     * Returns position adjusted for current time
     */
    func getPosition() -> Double {
        let startTime = self.receivedAt.addingTimeInterval(-Double(self.playback.position))
        return min(-startTime.timeIntervalSinceNow, Double(self.playback.length))
    }
    
}

class StatusPlayback: NSObject, Codable {
    var songId: String
    var artist: String
    var title: String
    var album: String
    var position: Int
    var length: Int
    var artwork: String
    var artworkSrc: String
    var artworkSm: String
    var artworkSmSrc: String
    var likes: Int
    var dislikes: Int
}
