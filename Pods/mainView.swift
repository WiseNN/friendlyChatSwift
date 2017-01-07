//
//  mainView.swift
//  FriendlyChatSwift
//
//  Created by Norris Wise on 1/7/17.
//  Copyright © 2017 Norris Swift Sample Application. All rights reserved.
//

import Foundation
import UIKit
class mainView : UIView {
    
    // the button is a subview of this view... try to tap it
    
    // normally, you can't touch a subview's region outside its superview
    // but you can *see* a subview outside its superview if the superview doesn't clip to bounds,
    // so why shouldn't you be able to touch it?
    // this hitTest override makes it possible
    // try the example with hitTest commented out and with it restored to see the difference
    override func hitTest(_ point: CGPoint, with e: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with:e) {
            return result
        }
        for sub in self.subviews.reversed() {
            let pt = self.convert(point, to:sub)
            if let result = sub.hitTest(pt, with:e) {
                return result
            }
        }
        return nil
    }
}
