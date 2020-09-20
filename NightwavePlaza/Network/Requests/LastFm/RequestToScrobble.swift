//
//  RequestToScrobble.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 21.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

class RequestToScrobble: NSObject, TRCRequest {
    
    var artist: String?
    var album: String?
    var title: String?
    
    var length: NSNumber?
    var timestamp: NSNumber?
    
    var token: String?
    
    func method() -> String! {
        return TRCRequestMethodPost;
    }
    
    func path() -> String! {
        return "scrobbler/scrobble";
    }
    
    func requestBodySerialization() -> String! {
        return TRCSerializationRequestHttp;
    }
    
    func responseBodySerialization() -> String! {
        return TRCSerializationString;
    }
    
    func requestBody() -> Any! {
        let dict = NSMutableDictionary()
        if let artist = self.artist {
            dict["artist"] = artist
        }
        if let album = self.album {
            dict["album"] = album
        }
        if let track = self.title {
            dict["track"] = track
        }
        if let timestamp = self.timestamp {
            dict["timestamp"] = timestamp
        }
        if let length = self.length {
            dict["length"] = length
        }
        return dict
    }
    
    func requestHeaders() -> [AnyHashable : Any]! {
        return [
            "x-lastfm-token": self.token ?? ""
        ]
    }
    
}
