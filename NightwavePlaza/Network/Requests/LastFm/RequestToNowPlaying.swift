//
//  RequestToNowPlaying.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 21.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

class RequestToNowPlaying: NSObject, TRCRequest {
    
    var artist: String?
    var album: String?
    var title: String?
    
    var token: String?
    
    func method() -> String! {
        return TRCRequestMethodPost;
    }
    
    func path() -> String! {
        return "scrobbler/nowplaying";
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
        return dict
    }
    
    func requestHeaders() -> [AnyHashable : Any]! {
        return [
            "x-lastfm-token": self.token ?? ""
        ]
    }
 
}
