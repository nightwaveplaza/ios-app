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
                  self.nowPlaying(playback: currentStatus.playback)
                }
            }
        }
        ).disposed(by: disposeBag)
        
        self.statusService?.status$.withPrevious()
            .subscribe(onNext: { (previous, current) in
                
                if let previous = previous, let previousPlayback = previous?.playback, let current = current {
                    if previousPlayback.songId != current.playback.songId {
                        if let playback = self.playbackService, playback.paused == false {
                            self.scrobble(playback: previousPlayback)
                            self.nowPlaying(playback: current.playback)
                        }
                    }
                }
            }
        ).disposed(by: disposeBag)
    }
    
    func nowPlaying(playback: StatusPlayback) {
        guard let token = LastFmService.getAccount()?.token else {
            return
        }
        
        let request = RequestToNowPlaying()
        request.token = token as String
        request.album = playback.album
        request.artist = playback.artist
        request.title = playback.title
        
        RestClient.shared.restClient.send(request) {[unowned self] (result, error) in
            
            if let _ = error {
                self.status = .Error
            } else {
                self.status = .Success
            }
        }
        
    }
    
    func scrobble(playback: StatusPlayback) {
        guard let token = LastFmService.getAccount()?.token else {
            return
        }
        
        let request = RequestToScrobble()
        request.token = token as String
        request.album = playback.album
        request.artist = playback.artist
        request.title = playback.title
        
        request.timestamp = NSNumber(value: NSDate().timeIntervalSince1970)
        request.length = NSNumber(value: playback.length)
        
        RestClient.shared.restClient.send(request) {[unowned self] (result, error) in
            
            if let _ = error {
                self.status = .Error
            } else {
                self.status = .Success
            }
        }
        
    }
    
}
