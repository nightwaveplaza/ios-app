//
//  MetadataService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import MediaPlayer

class MetadataService {
    
    var playback: PlaybackService
    
    init(playback: PlaybackService) {
        self.playback = playback
    }
    
    func setMetadata(status: Status) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyArtist] = status.playback.artist
        nowPlayingInfo[MPMediaItemPropertyTitle] = status.playback.title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = status.playback.album
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.playback.player.rate
        
        if let image = status.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = status.getPosition()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = status.playback.length

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
