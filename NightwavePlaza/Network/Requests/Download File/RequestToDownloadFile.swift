//
//  RequestToDownloadFile.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 06.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation


class RequestToDownloadFile: NSObject, TRCRequest {
    
    var url: String!
    
    var outputPath: String?
    
    func method() -> String! {
        return TRCRequestMethodGet;
    }
    
    func path() -> String! {
        return self.url;
    }
    
    func responseBodySerialization() -> String! {
        return TRCSerializationData
    }
    
    func responseBodyOutputStream() -> OutputStream! {
        
        if let path = outputPath {
            return OutputStream(toFileAtPath: path, append: false)
        } else {
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: false)
            
            var pathExt = (self.url as NSString).pathExtension
            if (pathExt as NSString).length == 0 {
                pathExt = "mp4"
            }
            
            let coverImageDir = temporaryDirectoryURL.appendingPathComponent("backgrounds")
            let localUrl = coverImageDir.appendingPathComponent("\(ProcessInfo().globallyUniqueString).\(pathExt)")
            
            
            do {
                if (!FileManager.default.fileExists(atPath: coverImageDir.path)) {
                    try FileManager.default.createDirectory(at: coverImageDir, withIntermediateDirectories: true, attributes: nil)
                }
            } catch {
                print("Unable to create cache directory")
            }
            
             
            self.outputPath = localUrl.path
            
            return OutputStream(toFileAtPath: localUrl.path, append: false)

        }
        
        
    }
    
    
    
}
