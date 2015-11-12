//
//  ViewController.swift
//  EasingExample
//
//  Created by Justin Forsyth on 10/27/15.
//  Copyright © 2015 jforce. All rights reserved.
//

import UIKit
import Easing

class ViewController: UIViewController, EasingFunctionPainterDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var orbView: OrbView!
    
    
    var painter: EasingFunctionPainter!;
    var currentFunction: EasingFunction!;
    
    var items: [String] = Array(EasingFunction.lut.keys).sort();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        painter = EasingFunctionPainter(imageView: self.imageView);
        
        painter.delegates.append(self);
        
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let margin: CGFloat = 20.0;
        
        
        imageView.frame = CGRectMake(margin, margin, self.view.frame.size.width - (2 * margin), (self.view.frame.size.height / 2) - (2 * margin));
        
        tableView.frame = CGRectMake(margin, (self.view.frame.size.height / 2), self.view.frame.size.width - (2 * margin), (self.view.frame.size.height / 2) - (margin));
        
        painter.orbView = orbView;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //begin EasingFunctionPainterDelegate implementation
    
    func paintStart(){
        
        //called when painting has started
        
    }
    
    func paintProgress(progress: Int){
        //called at each percentage of paint progress (0-100)
        
    }
    
    func paintComplete(){
        
        //called when painting has completed
        painter.clear();
        painter.paint(currentFunction)
        
        
    }
    
    func prepareStart() {
        
        //called when frame preparation has started
    }
    
    
    func prepareComplete() {
        //called when frame preparation has completed
        
    }
    
    func canceled() {
        
        painter.clear();
        painter.paint(currentFunction)
        
        
    }
    
    //end EasingFunctionPainterDelegate implementation
    
    //begin UITableViewDataSource implementation
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    //end UITableViewDataSource implementation
    
    //begin UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        
        //Use EasingFunction's look up table to find the appropriate EasingFunction to paint
        currentFunction = EasingFunction.lut[(tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!]!
        
        if(painter.state == EasingFunctionPainterState.Idle){

            painter.paint(currentFunction);
        }
        else{
            painter.cancel();
            
            
        }
        
    }
    
    //end UITableViewDelegate



}

