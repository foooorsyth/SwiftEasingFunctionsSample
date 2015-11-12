//
//  Tracker.swift
//  EasingExample
//
//  Created by Justin Forsyth on 11/3/15.
//  Copyright © 2015 jforce. All rights reserved.
//

import Foundation
import UIKit

class OrbView : UIView {
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.redColor().setFill()
        path.fill()
    }
    
}