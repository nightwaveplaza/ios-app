//
//  WebViewController.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 02.08.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import WebKit
import PureLayout
import RxCocoa
import RxSwift

class WebViewController: UIViewController {
    
    let backgroundView = BackgroundView()
    let webView = WKWebView()
    
    private var disposeBag = DisposeBag()
    
    private let statusService = StatusService()
    private let playback: PlaybackService
    private let metadata: MetadataService
    
    private let webBridge = WebBridgeService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.playback = PlaybackService();
        self.metadata = MetadataService(playback: playback)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        self.playback = PlaybackService();
        self.metadata = MetadataService(playback: playback)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        self.view.addSubview(backgroundView)
        backgroundView.autoPinEdgesToSuperviewEdges()
        
        self.setupWebView()
        
        self.webBridge.setup(webView: self.webView, statusService: self.statusService, playback: self.playback, metadata: self.metadata);
        self.webBridge.viewController = self;
    }
    
    
    func setupWebView() {
        self.view.addSubview(webView);
        webView.autoPinEdgesToSuperviewEdges()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        let webPath = (Bundle.main.bundlePath as NSString).appendingPathComponent("web");
        let indexPath = (webPath as NSString).appendingPathComponent("index.html");
        
        let indexContent = try! NSString(contentsOfFile: indexPath, encoding: String.Encoding.utf8.rawValue);
 
        webView.loadHTMLString(indexContent as String, baseURL: URL(fileURLWithPath: webPath));
    }
    
}

