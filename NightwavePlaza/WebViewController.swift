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

class WebViewController: UIViewController, WKNavigationDelegate {
    
    let backgroundView = BackgroundView()
    let webView = WKWebView()
    
    private var disposeBag = DisposeBag()
    
    private let statusService = StatusService()
    private let playback: PlaybackService
    private let metadata: MetadataService
    
    private let webBridge = WebBridgeService()
    
    private var selectionWasDisabled = false
    
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
        
        self.webBridge.setup(webView: self.webView, statusService: self.statusService, playback: self.playback, metadata: self.metadata);
        self.webBridge.viewController = self;
        
        self.setupWebView()
    }
    
    
    func setupWebView() {
        self.view.addSubview(webView);
        webView.autoPinEdgesToSuperviewEdges()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        
        let webPath = (Bundle.main.bundlePath as NSString).appendingPathComponent("web");
        let indexPath = (webPath as NSString).appendingPathComponent("index.html");
        
        let indexContent = try! NSString(contentsOfFile: indexPath, encoding: String.Encoding.utf8.rawValue);
 
        webView.loadHTMLString(indexContent as String, baseURL: URL(fileURLWithPath: webPath));
        webView.navigationDelegate = self
        
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if selectionWasDisabled == false {
            let javascriptStyle =
            """
                var css = 'input[type=text],input[type=password], input[type=email], input[type=number], input[type=time], input[type=date], textarea {-webkit-touch-callout: auto;-webkit-user-select: auto;} *{-webkit-touch-callout:none;-webkit-user-select:none}';
                var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);
            """
            webView.evaluateJavaScript(javascriptStyle, completionHandler: nil)
            selectionWasDisabled = true
        }
    }
    
}

