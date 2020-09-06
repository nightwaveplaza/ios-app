//
//  StartMenuHandler.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 06.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import UIKit
import GestureRecognizerClosures

class StartMenuHandler {
    
    static func menuItems() -> [StartMenuItem] {
        return [
            StartMenuItem(icon: UIImage(named: "ic_ratings"), title: "Ratings", targetAction: "ratings", hasBottomLine: true),
            StartMenuItem(icon: UIImage(named: "ic_favorites"), title: "My Favorites", targetAction: "user-favorites", hasBottomLine: false),
            StartMenuItem(icon: UIImage(named: "ic_profile"), title: "My Profile", targetAction: "user", hasBottomLine: true),
            StartMenuItem(icon: UIImage(named: "ic_settings"), title: "Settings", targetAction: "settings", hasBottomLine: false),
            StartMenuItem(icon: UIImage(named: "ic_help"), title: "About", targetAction: "about", hasBottomLine: false),
            StartMenuItem(icon: UIImage(named: "ic_launcher"), title: "Support", targetAction: "support", hasBottomLine: true)
        ]
    }
    
    static func showMenu(inViewController viewController: UIViewController, onSelect block: @escaping (_ action: String) -> Void) {
    
        let view = StartMenuView()
        view.setup(items: self.menuItems(), viewController: viewController)
        
        let darkView = UIView()
        darkView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        viewController.view.addSubview(darkView);
        darkView.autoPinEdgesToSuperviewEdges()
    
        viewController.view.addSubview(view);
        
        var left: NSLayoutConstraint?;
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            left = view.autoPinEdge(toSuperviewEdge: .left)
        }
        
        view.autoPinEdge(toSuperviewEdge: .bottom)
        view.updateConstraints()
        view.layoutIfNeeded()
        left?.constant = -view.bounds.size.width;

        self.animatePresentation(darkView: darkView, menuView: view, left: left)
        
        view.onClick = { item in
            block(item.targetAction)
            self.animateDismiss(darkView: darkView, menuView: view, left: left)
        }
        
        darkView.onTap { (handler) in
            self.animateDismiss(darkView: darkView, menuView: view, left: left)
        }
    }
    
    static func animatePresentation(darkView: UIView, menuView: UIView, left: NSLayoutConstraint?) {
        menuView.superview!.layoutIfNeeded()
        UIView.setAnimationCurve(.easeInOut)
        UIView.animate(withDuration: 0.2, animations: {
            darkView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            left?.constant = 0;
            menuView.superview!.layoutIfNeeded()
        }) { (finished) in

        }
    }
    
    static func animateDismiss(darkView: UIView, menuView: UIView, left: NSLayoutConstraint?) {
        menuView.superview!.layoutIfNeeded()
        UIView.setAnimationCurve(.easeInOut)
        UIView.animate(withDuration: 0.2, animations: {
            darkView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            left?.constant = -menuView.bounds.size.width;
            menuView.superview!.layoutIfNeeded()
        }) { (finished) in
            darkView.removeFromSuperview()
            menuView.removeFromSuperview()
        }
    }
    
    
    
    
}
