//
//  BackgroundCacheManager.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 06.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import Reachability

class BackgroundCacheManager {
    
    static let shared = BackgroundCacheManager()
    
    let reachability = try! Reachability()
    var shouldPrecache = true

    func precacheAllOnWifi() {
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                if self.shouldPrecache {
                    self.precacheAll()
                    self.shouldPrecache = false;
                }
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    func precacheAll() {
        RestClient.shared.restClient.send(RequestToGetBackgrounds()) {[unowned self] (result, error) in

            if let bg = result as? [[String: Any]] {
                for bgItem in bg {
                    let videoUrl = URL(string: bgItem["video_src"] as! String)!
                    self.getLocalUrl(remoteUrl: videoUrl) { (res, err) in }
                }
            }
        }
    }
    
    func getLocalUrl(remoteUrl: URL, result: @escaping (_ result: URL?, _ error: Error?) -> Void) -> Void {
        
        let localUrl = self.urlForLocalVideo(remoteUrl: remoteUrl)
        if FileManager.default.fileExists(atPath: localUrl.path) {
            result(localUrl, nil)
            return
        }
        
        
        let request = RequestToDownloadFile()
        request.url = remoteUrl.absoluteString

        RestClient.shared.restClient.send(request) { (image, error) in
            
            if let path = request.outputPath {
                try? FileManager.default.moveItem(at: URL(fileURLWithPath: path), to: localUrl)
                result(localUrl, nil)
            } else {
                result(nil, error)
            }
            

        }
        
    }
    
    func urlForLocalVideo(remoteUrl: URL) -> URL {
        let dir = self.getDocumentsDirectory().appendingPathComponent("backgroundVideos")
        do {
            if (!FileManager.default.fileExists(atPath: dir.path)) {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            
        }
        
        var pathExt = (remoteUrl.absoluteString as NSString).pathExtension
        if (pathExt as NSString).length == 0 {
            pathExt = "mp4"
        }
        
        let hash = (remoteUrl.absoluteString as NSString).sha1()!
        return dir.appendingPathComponent("\(hash).\(pathExt)")
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
