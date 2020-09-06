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
        
        
        viewController.view.addSubview(self.tooltipTarget)
        self.tooltipTarget.backgroundColor = UIColor.clear
        self.tooltipTarget.autoSetDimensions(to: CGSize(width: 30, height: 30))
        self.tooltipTarget.autoPinEdge(toSuperviewEdge: .bottom)
        self.tooltipTarget.autoPinEdge(toSuperviewEdge: .right, withInset: 40)
        
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
        else if message.name == "getVote" {
            
            completion(self.currentVote(), nil)
        }
        else if message.name == "updateVote" {
            
            completion(nil, nil)
        }
        else if message.name == "showToast" {
            print("Toast: \(message.args[0])")
            self.showTooltip(message.args[0])
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
            
            let time = self.sleepTimer.milisecondsSince1970ToSleep()
            if time < 1 {
                playback["sleepTime"] = Int(0)
            } else {
                playback["sleepTime"] = time
            }
            
            
            return playback
        } else {
            return NSDictionary()
        }
    }
    
    private func currentVote() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["artist"] = "";
        dict["title"] = "";
        dict["artwork"] = "";
        dict["rate"] = 0;
        return dict;
    }
    
    private func showTooltip(_ text: String) {
        
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
        preferences.drawing.arrowHeight = 33
        preferences.drawing.cornerRadius = 15
        preferences.positioning.bubbleHInset = 30
        preferences.drawing.borderColor = .black
        preferences.drawing.arrowWidth = 36
        preferences.drawing.borderWidth = 1
        
        self.currentTooltip = EasyTipView.show(forView: self.tooltipTarget,
                         withinSuperview: self.viewController!.view,
        text: text,
        preferences: preferences,
        delegate: nil)
    }
    
    
    
}
