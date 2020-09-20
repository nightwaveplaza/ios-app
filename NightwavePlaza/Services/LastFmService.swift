//
//  LastFmService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 13.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

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
            if let lastFmAccount = account as? LastFmAccount, let _ = lastFmAccount.token {
                return lastFmAccount
            }
        }
        return nil
    }
    
    static func storeAccount(account: LastFmAccount) {
        self.storage?.save(account)
    }
    
    
    var status: LastFmServiceStatus = .Idle
    
    weak var playbackService: PlaybackService?
    weak var statusService: StatusService?
    
    init(playback: PlaybackService, status: StatusService) {
        self.playbackService = playback
        self.statusService = status
        
        self.setupEvents()
    }
    
    func setupEvents() {
        
    }
    
}
