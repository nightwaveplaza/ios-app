//
//  RestClient.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation


class RestClient: CCAPIClient {
    
    static var shared = RestClient()
    
    override init() {
        super.init()
        self.enableLogging = false;
        self.baseUrl = URL(string: "https://api.plaza.one/")!
    }
    
}
