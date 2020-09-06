//
//  WebBridgeService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 16.08.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import WebKit
import RxCocoa
import RxSwift

class WebBridgeService: NSObject, WebBusDelegate {
    
    weak var viewController: WebViewController?
    
    private var disposeBag = DisposeBag()
    
    private var statusService: StatusService!
    private var playback: PlaybackService!
    private var metadata: MetadataService!
    
    private let webBus = WebMessageBus()
    
    private var sleepTimer: SleepTimerService!
    
    func setup(
        webView: WKWebView,
        statusService: StatusService,
        playback: PlaybackService,
        metadata: MetadataService
    ) {
        self.playback = playback;
        self.metadata = metadata;
        self.statusService = statusService
        self.sleepTimer = SleepTimerService(playback: self.playback)
        self.sleepTimer.onSleep = { [unowned self] in
            self.sendCurrentStatus()
        }
        webBus.webView = webView
        
        self.bindEvents()
    }
    
    func bindEvents() {
        webBus.delegate = self;
        statusService.status$.subscribe { [weak self] (event) in
            if let status = event.element as? Status {
                self?.metadata.setMetadata(status: status)
                self?.webBus.sendSongStatus(status: status, playing: self?.playback.paused == false)
            }
        }.disposed(by: disposeBag)
        
        
        statusService.status$.subscribe({ (event) in
           switch event {
           case .next(let status):
               print("Received a status: \(String(describing: status))")
           case .error(_):
               break
           case .completed:
               break
               
           }
       }).disposed(by: disposeBag)
        
    }
    
    
    func webBusDidReceiveMessage(message: WebMessage, completion: @escaping (Any?, String?) -> Void) {
        
        print("Received message: \(message.name)")
        
        if message.name == "requestUiUpdate" {
            self.sendCurrentStatus()
            completion(nil, nil)
        }
        else if message.name == "getStatus" {
          if let status = try? statusService.status$.value() {
              let songObject = self.songObject(status: status, isPlaying: self.playback.paused == false)
            completion(songObject, nil)
          } else {
            completion(nil, nil)
          }
        } else if message.name == "audioPlay" {
            self.playback.player.play()
            completion(nil, nil)
        } else if message.name == "audioStop" {
            self.playback.player.pause()
            completion(nil, nil)
        } else if message.name == "openDrawer" {
            if let controller = self.viewController {
                StartMenuHandler.showMenu(
                    inViewController: controller,
                    onSelect: { action in
                        self.webBus.sendMessage(name: "openWindow", data: [ "window": action ])
                    
                })
            }
            completion(nil, nil)
        } else if message.name == "getAuthToken" {
            if let token = AuthStorage.getKey() {
                completion("'\(token)'", nil)
            } else {
                completion("''", nil)
            }
        } else if message.name == "setAuthToken" {
            AuthStorage.storeKey(key: message.args[0] as NSString)
            completion(nil, nil)
        } else if message.name == "setBackground" {
            if message.args[0] == "solid" {
                viewController?.backgroundView.setSolid()
            } else {
                let url = URL(string: message.args[0])!
                viewController?.backgroundView.setUrl(url: url)
            }
            completion(nil, nil)
        } else if message.name == "getUserAgent" {
            completion("'NightwavePlaza iOS App'", nil)
        } else if message.name == "toggleFullscreen" {
            self.viewController?.fullScreen = !(self.viewController?.fullScreen ?? true)
            UIView.animate(withDuration: 0.5,
                       animations: {
                        self.viewController?.setNeedsStatusBarAppearanceUpdate()
                   })
            completion(nil, nil)
        } else if message.name == "getAppVersion" {
            let dictionary = Bundle.main.infoDictionary!
            let versionValue = dictionary["CFBundleShortVersionString"] ?? "0"
            let buildValue = dictionary["CFBundleVersion"] ?? "0"
            
            completion("'\(versionValue) (build \(buildValue))'", nil)
        } else if message.name == "getIapStatus" {
            completion("0", nil)
        }
        else if message.name == "getAudioQuality" {
            completion("\(playback.quality.rawValue)", nil)
        }
        else if message.name == "setAudioQuality" {
            if let qualityInt = Int(message.args[0]), let quality = PlaybackQuality(rawValue: qualityInt) {
                playback.quality = quality
            }
            completion("\(playback.quality.rawValue)", nil)
        }
        else if message.name == "setSleepTimer" {
            if let timeInMinutes = Double(message.args[0]) {
                self.sleepTimer.sleepAfter(minutes: timeInMinutes)
            }
            completion(nil, nil)
        }
 
        else {
            print("Unhandled message: \(message.name)")
        }
        
    }
    
    private func sendCurrentStatus() {
        if let status = try? statusService.status$.value() {
            let songObject = self.songObject(status: status, isPlaying: self.playback.paused == false)
            self.webBus.sendMessage(
                name: "status",
                data: songObject)
        }
    }
    
    private func songObject(status: Status, isPlaying playing: Bool) -> NSDictionary {
        if let dict = status.raw as? NSMutableDictionary {
            let playback = (dict["playback"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if let imageFileUrl = status.imageFileUrl {
                playback["artworkFilename"] = imageFileUrl.absoluteString
            }
            playback["isPlaying"] = playing
            playback["updated"] = status.receivedAt.timeIntervalSince1970 * 1000
            playback["sleepTime"] = self.sleepTimer.secondsToSleep()
            
            return playback
        } else {
            return NSDictionary()
        }
    }
    
    
    
}
