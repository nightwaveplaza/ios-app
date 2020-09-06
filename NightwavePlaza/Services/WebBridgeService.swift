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
                self?.webBus.sendSongStatus(status: status, playing: self?.playback.paused == false)
//                self?.webBus.sendMessage(name: "status", data: status.raw)
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
    
    
    func webBusDidReceiveMessage(message: WebMessage, completion: @escaping (NSObject?, String?) -> Void) {
        print("Received a message: \(message.name)")
        
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
        }
        
        else {
            print("Unhandled message: \(message.name)")
        }
        
    }
    
    
    
}
