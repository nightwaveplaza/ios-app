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
    var previousStatus: Status?
    
    init(playback: PlaybackService) {
        self.playback = playback
    }
    
    func setMetadata(status: Status, isPlaying: Bool) {
        if (isPlaying == false) {
            clearMetadata()
            return
        }
        if (UIApplication.shared.applicationState == UIApplication.State.active ) {
            // Only update metadata for inactive & background stated apps
            return
        }
        
        if (status.song.id == previousStatus?.song.id) {
            setPlaybackPositionMetadata(status: status)
        } else {
            setFullMetadata(status: status)
        }
        previousStatus = status
    }
    
    func clearMetadata() {
        previousStatus = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func setFullMetadata(status: Status) {
        print("Set full metadata")
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyArtist] = status.song.artist
        nowPlayingInfo[MPMediaItemPropertyTitle] = status.song.title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = status.song.album
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.playback.player.rate
        
        if let image = status.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = status.getPosition()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = status.song.length

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setPlaybackPositionMetadata(status: Status) {
        print("Set partial metadata")
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String : Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = status.getPosition()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = status.song.length
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
