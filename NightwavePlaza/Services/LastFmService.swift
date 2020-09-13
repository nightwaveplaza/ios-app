//
//  LastFmService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 13.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation


class LastFmService {
    
    static let storage = CCKeychainStorage(with: NSString.classForCoder(), accountName: "lastFmToken", serviceName: "NightwavePlaza.account")
    
    static func getKey() -> NSString? {
        return self.storage?.getObject() as? NSString
    }
    
    static func storeKey(key: NSString) {
        self.storage?.save(key)
    }
    
}
