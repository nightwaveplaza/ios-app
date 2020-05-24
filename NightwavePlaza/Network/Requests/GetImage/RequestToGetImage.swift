//
//  RequestToGetImage.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

class RequestToGetImage: NSObject, TRCRequest  {
    
    private var imageUrl: String
    
    init(url: String) {
        self.imageUrl = url
    }
    
    
    func path() -> String {
        return self.imageUrl
    }
    
    func method() -> String {
        return TRCRequestMethodGet;
    }
    
    func responseBodySerialization() -> String! {
        return TRCSerializationResponseImage
    }
    
}
