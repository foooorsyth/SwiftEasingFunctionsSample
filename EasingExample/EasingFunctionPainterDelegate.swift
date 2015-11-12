//
//  EasingFunctionPainterDelegate.swift
//  EasingExample
//
//  Created by Justin Forsyth on 10/29/15.
//  Copyright © 2015 jforce. All rights reserved.
//

import Foundation

//Delegate for a Painter's events
protocol EasingFunctionPainterDelegate {
    
    
    func paintStart();
    
    func paintProgress(progress: Int);
    
    func paintComplete();
    
    func prepareStart();
    
    func prepareComplete();
    
    func canceled();
    
    
}