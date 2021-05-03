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

// Clean up!!!
class WebBridgeService: NSObject, WebBusDelegate {
    
    weak var viewController: WebViewController?
    
    private var disposeBag = DisposeBag()
    
    private var statusService: StatusService!
    private var playback: PlaybackService!
    private var metadata: MetadataService!
    
    private let webBus = WebMessageBus()
    
    private var sleepTimer: SleepTimerService!
    
    private let tooltipTarget = UIView()
    private var currentTooltip: EasyTipView?
    
    private var startMenuHandler = StartMenuHandler()
    
    func setup(
        webView: WKWebView,
        statusService: StatusService,
        playback: PlaybackService,
        metadata: MetadataService,
        viewController: WebViewController
    ) {
        self.playback = playback;
        self.metadata = metadata;
        self.statusService = statusService
        self.sleepTimer = SleepTimerService(playback: self.playback)
        self.sleepTimer.onSleep = { [unowned self] in
            self.sendCurrentStatus()
        }
        webBus.webView = webView
        
        self.viewController = viewController
        
        startMenuHandler.setup(inViewController: viewController, onSelect: { action in
            if action == "user-favorites" && AuthStorage.getKey() == nil {
                self.webBus.sendMessage(name: "openWindow", data: [ "window": "user-login" ])
            } else {
                self.webBus.sendMessage(name: "openWindow", data: [ "window": action ])
            }
        })
        
        self.bindEvents()
    }
    
    func bindEvents() {
        webBus.delegate = self;
        
        
        playback.playbackRate$.subscribe({ [unowned self] (event) in
            self.sendCurrentStatus()
        }).disposed(by: disposeBag)
        
        statusService.status$.subscribe { [unowned self] (event) in
            if let status = event.element as? Status {
                self.metadata.setMetadata(status: status)
                
                let song = self.songObject(status: status, isPlaying: self.playback.paused == false)
                self.webBus.sendMessage(name: "status", data: song)
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
            self.playback.play()
            completion(nil, nil)
        } else if message.name == "audioStop" {
            self.playback.pause()
            completion(nil, nil)
        } else if message.name == "openDrawer" {
            self.startMenuHandler.show()
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
            self.sendCurrentStatus()
        }
        else if message.name == "getReaction" {
            
            completion(self.currentReaction(), nil)
        }
        else if message.name == "setReaction" {
            
            completion(nil, nil)
        }
        else if message.name == "showToast" {
            self.showTooltip(message.args[0])
            completion(nil, nil)
        }
        else if message.name == "setLastfmToken" {
            let account = LastFmAccount(token: message.args[0] as NSString, username: message.args[1] as NSString)
            LastFmService.storeAccount(account: account)
            completion(nil, nil)
        }
        else if message.name == "getLastfmUsername" {
            if let account = LastFmService.getAccount() {
                completion("'\(account.username ?? "")'", nil)
            } else {
                completion("''", nil)
            }
        }
        else if message.name == "getLastfmStatus" {
            if let status = self.viewController?.lastFmService.status {
                completion("'\(status.rawValue)'", nil)
            } else {
                 completion("''", nil)
            }
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
        if let dict = status.raw as? NSDictionary {
            let song = (dict["song"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if let imageFileUrl = status.imageFileUrl {
                song["artworkFilename"] = imageFileUrl.absoluteString
            }
            song["isPlaying"] = playing
            song["updated"] = status.receivedAt.timeIntervalSince1970 * 1000
            
            let time = self.sleepTimer.milisecondsSince1970ToSleep()
            if time < 1 {
                song["sleepTime"] = Int(0)
            } else {
                song["sleepTime"] = time
            }
            
            song["likes"] = status.song.reactions.like
            song["dislikes"] = status.song.reactions.dislike
            
            return song
        } else {
            return NSDictionary()
        }
    }
    
    private func currentReaction() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["songId"] = "";
        dict["score"] = 0;
        return dict;
    }
    
    private func showTooltip(_ text: String) {
        
        if self.tooltipTarget.superview == nil {
            self.viewController!.view.addSubview(self.tooltipTarget)
            self.tooltipTarget.backgroundColor = UIColor.clear
            self.tooltipTarget.autoSetDimensions(to: CGSize(width: 30, height: 0))
            self.tooltipTarget.autoPinEdge(toSuperviewEdge: .bottom, withInset: self.viewController!.bottomLayoutGuide.length)
            self.tooltipTarget.autoPinEdge(toSuperviewEdge: .right, withInset: 40)
            
            self.viewController!.view.layoutSubviews()
            
        }
        if let current = self.currentTooltip {
            current.dismiss()
        }
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont.systemFont(ofSize: 15)
        preferences.drawing.foregroundColor = .black
        preferences.drawing.backgroundColor = UIColor(hex: "FBFBDE")!
        preferences.drawing.arrowPosition = .bottom
        preferences.animating.showDuration = 0
        preferences.animating.dismissDuration = 0
        preferences.drawing.arrowHeight = 25
        preferences.drawing.cornerRadius = 15
        preferences.positioning.bubbleHInset = 30
        preferences.drawing.borderColor = .black
        preferences.drawing.arrowWidth = 27
        preferences.drawing.borderWidth = 1
        preferences.drawing.shadowColor = .black
        preferences.drawing.shadowRadius = 2
        preferences.drawing.shadowOpacity = 1
        preferences.drawing.shadowOffset = CGSize(width: 1, height: 1)
        
        self.currentTooltip = EasyTipView.show(forView: self.tooltipTarget,
                         withinSuperview: self.viewController!.view,
        text: text,
        preferences: preferences,
        delegate: nil)
    }
    
    
    
}
