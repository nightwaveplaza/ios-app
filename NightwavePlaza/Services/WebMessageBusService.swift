//
//  WebBridgeService.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 02.08.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import WebKit

class WebMessage: NSObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case args
        case callbackId
    }
    
    var name: String
    var args: [String]
    var callbackId: String

}

@objc protocol WebBusDelegate: NSObjectProtocol {
    func webBusDidReceiveMessage(message: WebMessage, completion: @escaping (Any?, String?) -> Void);
}


class WebMessageBus: NSObject, WKScriptMessageHandler {
    
    weak var webView: WKWebView? {
        didSet {
            self.webView?.configuration.userContentController.add(self, name: "plaza")
        }
    }
    weak var delegate: WebBusDelegate?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
                
        guard let decoded = try? decoder.decode(WebMessage.self, from: JSONSerialization.data(withJSONObject: message.body, options: .fragmentsAllowed)) else {
            print("Unable to decode a message from Web: \(message.body)")
            return;
        }
        
        self.delegate?.webBusDidReceiveMessage(message: decoded, completion: {[weak self] (result, error) in
            // TODO: Cleanup this method
            guard let self = self else { return };
            var errorMessage = "undefined";
            if let error = error {
                errorMessage = "'\(error)'";
            }
            let resultValue = self.jsObjectStringFromObject(object: result);
            let jsMessage = "window['ios-callback']['\(decoded.callbackId)'](\(resultValue), \(errorMessage)); 'ok'; "
            self.webView?.evaluateJavaScript(jsMessage, completionHandler: { (res, err) in
//                print("Callback Result: \(String(describing: res))")
                if err != nil {
                    print("Unable to send js message: \(jsMessage). Error = \(String(describing: err))")
                } else {
//                    print("Return value called: \(jsMessage)");
                }
            });
        });
        
    }
    
    func sendSongStatus(status: Status, playing: Bool) {
        if let dict = status.raw as? NSMutableDictionary {
            let playback = (dict["playback"] as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if let imageFileUrl = status.imageFileUrl {
                playback["artworkFilename"] = imageFileUrl.absoluteString
            }
            playback["isPlaying"] = playing
            playback["updated"] = status.receivedAt.timeIntervalSince1970 * 1000
            
            self.sendMessage(name: "status", data: playback)
        }
        
    }
    
    func sendMessage(name: String, data: Any?) {

        let dataString = self.jsObjectStringFromObject(object: data)
        
        let jsMessage = "window['plaza'].push('\(name)', \(dataString)); 'ok'; "
        print("Sending a message. Name=\(name). Data=\(dataString)")
        webView?.evaluateJavaScript(jsMessage, completionHandler: { (res, err) in
            print("Send Message Result: \(String(describing: res)), error = \(String(describing: err))")
        })
    }
    
    private func jsObjectStringFromObject(object: Any?) -> String {
        do {
            guard let object = object else {
                return "undefined";
            }
            if let str = object as? String {
                return str;
            }
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
            return String(data: jsonData, encoding: .utf8)!
        } catch {
            return "undefined";
        }
    }
    
    
}
