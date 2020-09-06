//
//  StartMenuView.swift
//  NightwavePlaza
//
//  Created by Aleksey Garbarev on 06.09.2020.
//  Copyright © 2020 Aleksey Garbarev. All rights reserved.
//

import Foundation
import PureLayout
import GestureRecognizerClosures

class StartMenuView: UIView {
    
    let itemHeight: CGFloat = 65.0
    
    var onClick: ((_ item: StartMenuItem) -> Void)?
    
    func setup(items: [StartMenuItem], viewController: UIViewController) -> Void {
        self.backgroundColor = UIColor(hex: "CBCBCB")
        
        let bottomInset = viewController.bottomLayoutGuide.length
        var width =  CGFloat(viewController.view.bounds.size.width) / 2
//        width = CGFloat.maximum(width, 230)
//        width = CGFloat.minimum(width, 250)
        width = 230 // Hardcoded width for now..
        
        self.autoSetDimension(.height, toSize: CGFloat(CGFloat(items.count) * itemHeight + bottomInset))
        self.autoSetDimension(.width, toSize: width)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        var lastView: UIView?
        
        for item in items {
            let view = self.createViewForItem(item)
            self.addSubview(view)
            view.autoPinEdge(toSuperviewEdge: .left, withInset: 30)
            view.autoPinEdge(toSuperviewEdge: .right)
            view.autoSetDimension(.height, toSize: itemHeight)

            if let viewToPin = lastView {
                view.autoPinEdge(.top, to: .bottom, of: viewToPin)
            } else {
                view.autoPinEdge(toSuperviewEdge: .top)
            }
            
            
            view.onTap({recognizer in
                if (recognizer.state == .ended) {
                    self.onClick?(item)
                }
            })
            
            lastView = view

        }
        
        let view = self.createTitleView(leftInset: bottomInset)
        self.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)
        view.autoSetDimension(.width, toSize: 30)
        
    }
    
    
    func createViewForItem(_ item: StartMenuItem) -> UIView {
        
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = item.icon
        
        view.addSubview(imageView)
        imageView.autoSetDimensions(to: CGSize(width: 40, height: 40))
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 14)
        
        let label = UILabel()
        label.text = item.title
        label.font = UIFont.systemFont(ofSize: 16)
        
        view.addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.autoPinEdge(.left, to: .right, of: imageView, withOffset: 14)
        
        if (item.hasBottomLine) {
            let separator = UIView()
            separator.backgroundColor = UIColor(hex: "AEAEAE")
            view.addSubview(separator)
            separator.autoSetDimension(.height, toSize: 2)
            separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        }
        
        return view
        
    }
    
    func createTitleView(leftInset: CGFloat) -> UIView {
        let view = StartMenuHeaderView()
        view.leftInset = leftInset
        return view;
    }
    
    
}
