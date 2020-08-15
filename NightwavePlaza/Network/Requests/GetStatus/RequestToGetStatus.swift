//
//  RequestToGetStatus.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 24.05.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation

class RequestToGetStatus: NSObject, TRCRequest  {
    
    func path() -> String {
        return "status"
    }
    
    func method() -> String {
        return TRCRequestMethodGet;
    }
    
    func responseProcessed(fromBody bodyObject: Any!, headers responseHeaders: [AnyHashable : Any]!, status statusCode: TRCHttpStatusCode) throws -> Any {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let decoded = try decoder.decode(Status.self, from: JSONSerialization.data(withJSONObject: bodyObject!, options: .fragmentsAllowed))
        decoded.raw = bodyObject
        return decoded
    }

}
