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
        case listeners
        case updatedAt
        case song
    }
    
    var listeners: Int = 0
    var updatedAt: TimeInterval = 0.0
    var song: Song
    
    var receivedAt = Date()
    var image: UIImage?
    var imageFileUrl: URL?

    var raw: Any?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let anotherStatus = object as? Status  {
            return self.isEqual(toStatus: anotherStatus)
        } else {
            return false
        }
    }
    
    func isEqual(toStatus: Status) -> Bool {
        return toStatus.song.id == self.song.id
    }
    
    func estimatedFinish() -> Date {
        let startTime = self.receivedAt.addingTimeInterval(-Double(self.song.position))
        return startTime.addingTimeInterval(Double(self.song.length))
    }
    
    /**
     * Returns position adjusted for current time
     */
    func getPosition() -> Double {
        let startTime = self.receivedAt.addingTimeInterval(-Double(self.song.position))
        return min(-startTime.timeIntervalSinceNow, Double(self.song.length))
    }
    
}

class Song: NSObject, Codable {
    var id: String
    var artist: String
    var title: String
    var album: String
    var position: Int
    var length: Int
    var artworkSrc: String
    var artworkSmSrc: String
    var reactions: Int
}
