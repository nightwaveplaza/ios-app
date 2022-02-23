//
//  LastFmService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 13.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LastFmAccount: NSObject {
    
    @objc var username: NSString?
    @objc var token: NSString?
    init(token: NSString, username: NSString) {
        self.username = username
        self.token = token
    }
    override init() {
        super.init()
    }
}

enum LastFmServiceStatus: String {
    case Idle
    case Error
    case Success
}

class LastFmService {
    
    static let storage = CCKeychainStorage(with: LastFmAccount.classForCoder(), accountName: "lastFmAccount", serviceName: "NightwavePlaza.account")
    
    static func getAccount() -> LastFmAccount? {
        // Hardcoded to disable LastFm feature at all
        // TODO: Remove it completely from the app!
        return nil
        
        if let account = self.storage?.getObject() {
            if let lastFmAccount = account as? LastFmAccount, let token = lastFmAccount.token, token.length > 0 {
                return lastFmAccount
            }
        }
        return nil
    }
    
    static func storeAccount(account: LastFmAccount) {
        if let token = account.token, token.length > 0 {
            self.storage?.save(account)
        } else {
            self.storage?.save(nil)
        }
        
    }
    
    
    var status: LastFmServiceStatus = .Idle
    
    weak var playbackService: PlaybackService?
    weak var statusService: StatusService?
    
    var disposeBag = DisposeBag()
    
    init(playback: PlaybackService, status: StatusService) {
        self.playbackService = playback
        self.statusService = status
        
        self.setupEvents()
    }
    
    func setupEvents() {
        
        self.playbackService?.playbackRate$.subscribe(onNext: { (value) in
            if let playback = self.playbackService, playback.paused == false {
                if let currentStatus = try? self.statusService?.status$.value() {
                  self.nowPlaying(song: currentStatus.song)
                }
            }
        }
        ).disposed(by: disposeBag)
        
        self.statusService?.status$.withPrevious()
            .subscribe(onNext: { (previous, current) in
                
                if let previous = previous, let previousSong = previous?.song, let current = current {
                    if previousSong.id != current.song.id {
                        if let playback = self.playbackService, playback.paused == false {
                            self.scrobble(song: previousSong)
                            self.nowPlaying(song: current.song)
                        }
                    }
                }
            }
        ).disposed(by: disposeBag)
    }
    
    func nowPlaying(song: Song) {
        guard let token = LastFmService.getAccount()?.token else {
            return
        }
        
        let request = RequestToNowPlaying()
        request.token = token as String
        request.album = song.album
        request.artist = song.artist
        request.title = song.title
        
        RestClient.shared.restClient.send(request) {[unowned self] (result, error) in
            
            if let _ = error {
                self.status = .Error
            } else {
                self.status = .Success
            }
        }
        
    }
    
    func scrobble(song: Song) {
        guard let token = LastFmService.getAccount()?.token else {
            return
        }
        
        let request = RequestToScrobble()
        request.token = token as String
        request.album = song.album
        request.artist = song.artist
        request.title = song.title
        
        request.timestamp = NSNumber(value: NSDate().timeIntervalSince1970)
        request.length = NSNumber(value: song.length)
        
        RestClient.shared.restClient.send(request) {[unowned self] (result, error) in
            
            if let _ = error {
                self.status = .Error
            } else {
                self.status = .Success
            }
        }
        
    }
    
}
