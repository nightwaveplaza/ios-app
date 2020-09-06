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
    
    func setup(
        webView: WKWebView,
        statusService: StatusService,
        playback: PlaybackService,
        metadata: MetadataService
    ) {
        self.playback = playback;
        self.metadata = metadata;
        self.statusService = statusService
        
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
            if let status = try? statusService.status$.value() {
                self.webBus.sendSongStatus(status: status, playing: self.playback.paused == false)
            }
            completion(nil, nil)
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
        }
        
        else {
            print("Unhandled message: \(message.name)")
        }
        
    }
    
    
    
}
