//
//  RequestToGetBackgrounds.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

class RequestToGetBackgrounds: NSObject, TRCRequest {
    
    func method() -> String! {
        return TRCRequestMethodGet;
    }
    
    func path() -> String! {
        return "backgrounds";
    }
    
}
