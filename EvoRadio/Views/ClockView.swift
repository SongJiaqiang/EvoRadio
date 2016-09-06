//
//  ClockView.swift
//  EvoRadio
//
//  Created by Jarvis on 9/6/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class ClockView: UIControl {

    var timeLabel: UILabel!
    var dayLabel: UILabel!
    var lineView: UIView!
    
    var timer: NSTimer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
        
        timer = NSTimer(timeInterval: 1, target: self, selector: #selector(timerHandle), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = frame.size.width
        let h = frame.size.height
        
        lineView.frame = CGRectMake(4, h*0.55, w-8, 1)
        timeLabel.frame = CGRectMake(0, 2, w, h*0.55)
        dayLabel.frame = CGRectMake(0, h*0.55, w, h*0.45)
    }
    
    deinit {
        if let _ = timer {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func prepareUI() {
        clipsToBounds = true
        layer.cornerRadius = 4
        layer.borderWidth = 2
        layer.borderColor = UIColor.grayColor().CGColor
        backgroundColor = UIColor(netHex: 0x000000, alpha: 0.8)
        
        timeLabel = UILabel()
        addSubview(timeLabel)
        timeLabel.font = UIFont.sizeOf12()
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .Center
        
        dayLabel = UILabel()
        addSubview(dayLabel)
        dayLabel.font = UIFont.systemFontOfSize(8)
        dayLabel.textColor = UIColor.whiteColor()
        dayLabel.text = "星期日"
        dayLabel.textAlignment = .Center

        lineView = UIView()
        addSubview(lineView)
        lineView.backgroundColor = UIColor.grayColor3()
        
    }
    
    func timerHandle() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateFormat = "EEEE-HH:mm"
        
        let formatterText = formatter.stringFromDate(NSDate())
        let day_time = formatterText.componentsSeparatedByString("-")
        
        dayLabel.text = day_time.first
        timeLabel.text = day_time.last
    }
}
