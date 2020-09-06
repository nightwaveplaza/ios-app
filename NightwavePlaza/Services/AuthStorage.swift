//
//  AuthStorage.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 06.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

class AuthStorage {
    
    static let storage = CCKeychainStorage(with: NSString.classForCoder(), accountName: "acountId", serviceName: "NightwavePlaza.account")
    
    static func getKey() -> NSString? {
        return AuthStorage.storage?.getObject() as? NSString
    }
    
    static func storeKey(key: NSString) {
        AuthStorage.storage?.save(key)
    }
}
