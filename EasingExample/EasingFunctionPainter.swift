//
//  EasingFunctionPainter.swift
//  EasingExample
//
//  Created by Justin Forsyth on 10/27/15.
//  Copyright © 2015 jforce. All rights reserved.
//

import Foundation
import UIKit
import Easing

//Paints an Easing Function's curve onto a UIImageView
public class EasingFunctionPainter {
    
    var imageView: UIImageView;
    var easingFunction: EasingFunction?;
    var delegates: [EasingFunctionPainterDelegate];
    var state: EasingFunctionPainterState;
    var orbView: OrbView? {
        
        didSet{
            
            if(orbView != nil){
                
                let bottom = imageView.frame.origin.y + (imageView.frame.height * 0.75) - (orbSize / 2.0);
                
                let right = imageView.frame.origin.x + imageView.frame.width - (orbSize / 2.0);
                
                orbView!.frame = CGRectMake(right, bottom, orbSize, orbSize);
            }
            
        }
        
    }
    
    private var xValues: [Float];
    private var yValues: [Float];
    private var isPrepared: Bool;
    private var condemnedToCancellation: Bool;
    
    private let duration: Double = 1.5;
    private let fps: Int = 60;
    private let orbSize: CGFloat;
    
    init(imageView: UIImageView){
        
        self.imageView = imageView;
        self.easingFunction = nil;
        self.delegates = [EasingFunctionPainterDelegate]();
        self.xValues = [Float]();
        self.yValues = [Float]();
        self.isPrepared = false;
        self.condemnedToCancellation = false;
        self.state = EasingFunctionPainterState.Idle;
        self.orbSize = self.imageView.frame.height / 15.0;
        self.orbView = nil;
        drawBorder();
        
    }
    
    convenience init(imageView: UIImageView, orbView: OrbView){
        
        self.init(imageView: imageView);
        self.orbView = orbView;
        
    }

    
    func paint(easingFunction: EasingFunction){
        
        if(!isPrepared || (self.easingFunction != nil && !(easingFunction.self === self.easingFunction!.self))){
            prepare(easingFunction);
        }
        
        paintStart();
        
        let count = xValues.count - 2;
        
        let timePerStep : Double = duration / Double(count);
        
        paintMainLoop(0, count: count, timePerStep: timePerStep, lastProgress: -1);
        
    }
    
    //clears the drawing canvas and redraws the border
    func clear(){
        self.imageView.image = nil;
        drawBorder();
        
    }
    
    //condemns the current function being painted to cancellation on next frame
    func cancel(){
        self.condemnedToCancellation = true;
        
    }
    
    //recursive main painting loop
    //one iteration per frame
    private func paintMainLoop(let i: Int, count: Int, timePerStep: Double, var lastProgress: Int){
        let start = NSDate();
        
        let fromX = CGFloat(xValues[i]);
        let fromY = CGFloat(yValues[i]);
        
        let toX = CGFloat(xValues[i + 1]);
        let toY = CGFloat(yValues[i + 1]);
        
        //draw the line
        drawLine(CGPoint(x: fromX, y: fromY),
            toPoint: CGPoint(x: toX, y: toY),
            color: UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0));
        
        //move the orb
        
        let right = imageView.frame.origin.x + imageView.frame.width - (orbSize / 2.0);
        
        orbView!.frame = CGRectMake(right, toY + (orbSize / 2.0), orbSize, orbSize);
        
        //fire paintProgress event
        let progress = Int((Float(i) / Float(count)) * 100.0);
        if(progress > lastProgress){
            paintProgress(progress);
            lastProgress = progress
        }
        
        if(i == count){
            paintComplete();
            return;
        }
        
        if(self.condemnedToCancellation){
            canceled();
            return;
        }
        
        let end = NSDate();
        
        //the time it took to draw this step in seconds
        let stepDrawTime: Double = end.timeIntervalSinceDate(start);
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64((timePerStep - stepDrawTime) * Double(NSEC_PER_SEC)));
        
        dispatch_after(time, dispatch_get_main_queue()) {
            self.paintMainLoop(i + 1, count: count, timePerStep: timePerStep, lastProgress: lastProgress)
        }
        
    }
    
    private func prepare(easingFunction: EasingFunction){
        
        prepareStart();
        
        self.easingFunction = easingFunction;
        
        xValues.removeAll();
        yValues.removeAll();

        let width = imageView.frame.size.width;
        let baseY = imageView.frame.size.height * 0.25;
        let height = imageView.frame.size.height * 0.5;
        
        var t: Float = 0.0;
        let step: Float = 1.0 / (Float(duration) * Float(fps));
        
        while(t <= 1.0){
            
            let from = try! self.easingFunction?.calculate(t, b: 0.0, c: 1.0, d: 1.0)
            
            let fromX = CGFloat(t) * width;
            let fromY = height - (CGFloat(from!) * height) + baseY;
            
            self.xValues.append(Float(fromX));
            self.yValues.append(Float(fromY));

            t += step;
        }
        
        self.isPrepared = true;
        
        prepareComplete();
        
    }
    
    
    private func drawBorder(){
        
        let borderColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        
        let top = imageView.frame.size.height * 0.25;
        let left = CGFloat(0.0);
        let right = imageView.frame.size.width;
        let bottom = imageView.frame.size.height * 0.75;
        
        //top
        drawLine(CGPoint(x: left, y: top), toPoint: CGPoint(x: right, y: top), color: borderColor);
        
        //right
        drawLine(CGPoint(x: right, y: top),
            toPoint: CGPoint(x: right, y: bottom),
            color: borderColor);
        
        //bottom
        drawLine(CGPoint(x: right, y: bottom),
            toPoint: CGPoint(x: left, y: bottom),
            color: borderColor);
        
        //left
        drawLine(CGPoint(x: left, y: bottom),
            toPoint: CGPoint(x: left, y: top),
            color: borderColor);

    }
    
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint, color: UIColor) {

        UIGraphicsBeginImageContext(imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
        
        var red : CGFloat = 0.0;
        var green: CGFloat = 0.0;
        var blue : CGFloat = 0.0;
        var alpha: CGFloat = 0.0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha);

        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)

        CGContextSetLineCap(context, CGLineCap.Square)
        CGContextSetLineWidth(context, 1.0)
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        CGContextStrokePath(context)
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 1.0
        UIGraphicsEndImageContext()
        
    }
    
    private func prepareStart(){
        
        //fire prepareStart event
        for delegate in delegates {
            delegate.prepareStart();
        }
        
        //set state to Preparing
        self.state = EasingFunctionPainterState.Preparing
    }
    
    private func prepareComplete(){
        //fire prepareComplete event
        for delegate in delegates {
            delegate.prepareComplete();
        }
        
    }
    
    private func canceled(){
        
        self.condemnedToCancellation = false;

        //fire canceled event
        for delegate in delegates {
            delegate.canceled();
        }

        self.state = EasingFunctionPainterState.Canceled
        
        
    }
    
    private func paintStart(){
        
        //fire paintStart event
        for delegate in delegates {
            delegate.paintStart();
        }
        
        //set state to Painting
        self.state = EasingFunctionPainterState.Painting
        
    }
    
    private func paintProgress(progress: Int){
        
        for delegate in delegates {
            delegate.paintProgress(progress);
        }
    }
    
    private func paintComplete(){
        //fire paintComplete event
        for delegate in delegates {
            delegate.paintComplete();
        }
        
        //set state to Complete
        self.state = EasingFunctionPainterState.Completed
        
    }
    
    
    
    
    
}