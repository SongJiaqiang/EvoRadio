//
//  SelectiveTimePanel.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/27.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class SelectiveTimePanel: UIView {
    private var weekView = UIView()
    private let nowButton = UIButton()
    private let okButton = UIButton()
    private let randomButton = UIButton()
    private let resultLabel = UILabel()
    
    var daysButtons = [UIButton]()
    var timesButtons = [UIButton]()
    
    var selectedDayIndex: Int = 0
    var selectedTimeIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        alpha = 0.98
        insertGradientLayer()
        prepareBottomButtons()
        prepareWeekCollectionView()
        
        if let indexes = CoreDB.getSelectedIndexes() {
            selectButtonAtDaysIndex(indexes["dayIndex"]!, timeOfDayIndex: indexes["timeIndex"]!)
        }else {
            nowButtonPressed(nowButton)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(netHex: 0x283E51).CGColor,UIColor(netHex: 0x4B79A1).CGColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.frame = frame
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }

    func prepareBottomButtons() {
        
        addSubview(nowButton)
        nowButton.titleLabel?.font = UIFont.sizeOf14()
        nowButton.titleLabel?.textColor = UIColor.whiteColor()
        nowButton.setTitle("当前时刻", forState: .Normal)
        nowButton.backgroundColor = UIColor(netHex: 0x457fca)
        nowButton.addTarget(self, action: #selector(SelectiveTimePanel.nowButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        addSubview(okButton)
        okButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        okButton.titleLabel?.textColor = UIColor.whiteColor()
        okButton.setTitle("确定", forState: .Normal)
        okButton.backgroundColor = UIColor.goldColor()
        okButton.addTarget(self, action: #selector(SelectiveTimePanel.okButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        addSubview(randomButton)
        randomButton.titleLabel?.font = UIFont.sizeOf14()
        randomButton.titleLabel?.textColor = UIColor.whiteColor()
        randomButton.setTitle("随机时刻", forState: .Normal)
        randomButton.backgroundColor = UIColor(netHex: 0x457fca)
        randomButton.addTarget(self, action: #selector(SelectiveTimePanel.randomButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        let buttonHeight: CGFloat = 40
        nowButton.snp_makeConstraints { (make) in
            make.height.equalTo(buttonHeight)
            make.leftMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
            make.right.equalTo(okButton.snp_left)
            make.width.equalTo(okButton)
        }
        
        randomButton.snp_makeConstraints { (make) in
            make.height.equalTo(buttonHeight)
            make.rightMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(okButton.snp_right)
            make.width.equalTo(okButton)
        }
        
        okButton.snp_makeConstraints { (make) in
            make.height.equalTo(buttonHeight)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(nowButton.snp_right)
            make.right.equalTo(randomButton.snp_left)
            make.width.equalTo(randomButton)
        }
        
        
    }
    
    func prepareWeekCollectionView() {
        let height = max(CoreDB.getAllDaysOfWeek().count, CoreDB.getAllTimesOfDay().count) * (30+10)
        let buttonHeight:CGFloat = 30
        let buttonwidth:CGFloat = 100
        let margin:CGFloat = 10
        let daysOfWeek = CoreDB.getAllDaysOfWeek()
        let timesOfDay = CoreDB.getAllTimesOfDay()
        let daysCount = daysOfWeek.count
        let timesCount = timesOfDay.count
        let contentHeight:CGFloat = CGFloat(max(daysCount, timesCount))*(buttonHeight+margin)
        
        addSubview(weekView)
        weekView.snp_makeConstraints { (make) in
            make.center.equalTo(snp_center)
            make.height.equalTo(height)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        addSubview(resultLabel)
        resultLabel.textAlignment = .Center
        resultLabel.font = UIFont.sizeOf16()
        resultLabel.textColor = UIColor.whiteColor()
        resultLabel.text = "星期一 ▪ 清晨"
        resultLabel.snp_makeConstraints { (make) in
            make.bottom.equalTo(weekView.snp_top).offset(-30)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        let closeButton = UIButton()
        addSubview(closeButton)
        closeButton.setImage(UIImage(named: "icon_close"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(SelectiveTimePanel.closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        closeButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.leftMargin.equalTo(10)
            make.topMargin.equalTo(30)
        }
        
        let daysContentView = UIView()
        addSubview(daysContentView)
        
        let timesContentView = UIView()
        addSubview(timesContentView)
        
        daysContentView.snp_makeConstraints { (make) in
            make.height.equalTo(contentHeight)
            make.centerY.equalTo(snp_centerY)
            make.leftMargin.equalTo(0)
            make.right.equalTo(timesContentView.snp_left)
            make.width.equalTo(timesContentView.snp_width)
        }
        timesContentView.snp_makeConstraints { (make) in
            make.height.equalTo(contentHeight)
            make.centerY.equalTo(snp_centerY)
            make.left.equalTo(daysContentView.snp_right)
            make.rightMargin.equalTo(0)
            make.width.equalTo(timesContentView.snp_width)
        }
        
        for i in 0..<daysCount {
            let button = UIButton()
            button.titleLabel?.font = UIFont.sizeOf12()
            button.titleLabel?.textColor = UIColor.whiteColor()
            button.setTitle(daysOfWeek[i], forState: .Normal)
            button.clipsToBounds = true
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.setBackgroundImage(UIImage.rectImage(UIColor(white: 1, alpha: 0.5)), forState: .Highlighted)
            button.setBackgroundImage(UIImage.rectImage(UIColor(netHex: 0x457fca)), forState: .Selected)
            button.addTarget(self, action: #selector(SelectiveTimePanel.daysButtonPressed(_:)), forControlEvents: .TouchUpInside)
            button.tag = 10+i
            daysContentView.addSubview(button)
            daysButtons.append(button)
            
            button.snp_makeConstraints(closure: { (make) in
                make.size.equalTo(CGSizeMake(buttonwidth, buttonHeight))
                make.centerX.equalTo(daysContentView.snp_centerX)
                make.topMargin.equalTo((buttonHeight+margin)*CGFloat(i))
            })
            
        }
        
        for i in 0..<timesCount {
            let button = UIButton()
            button.titleLabel?.font = UIFont.sizeOf12()
            button.titleLabel?.textColor = UIColor.whiteColor()
            button.setTitle(timesOfDay[i], forState: .Normal)
            button.clipsToBounds = true
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.setBackgroundImage(UIImage.rectImage(UIColor(white: 1, alpha: 0.5)), forState: .Highlighted)
            button.setBackgroundImage(UIImage.rectImage(UIColor(netHex: 0x457fca)), forState: .Selected)
            button.addTarget(self, action: #selector(SelectiveTimePanel.timesButtonPressed(_:)), forControlEvents: .TouchUpInside)
            button.tag = 20+i
            timesContentView.addSubview(button)
            timesButtons.append(button)
            
            button.snp_makeConstraints(closure: { (make) in
                make.size.equalTo(CGSizeMake(buttonwidth, buttonHeight))
                make.centerX.equalTo(timesContentView.snp_centerX)
                make.topMargin.equalTo((buttonHeight+margin)*CGFloat(i))
            })
            
        }
        
    }

    //MARK: event
    func nowButtonPressed(button: UIButton) {
        selectButtonAtDaysIndex(CoreDB.currentDayOfWeek(), timeOfDayIndex: CoreDB.currentTimeOfDay())
    }
    
    func randomButtonPressed(button: UIButton) {
        let d = arc4random_uniform(7)
        let t = arc4random_uniform(8)
        selectButtonAtDaysIndex(Int(d), timeOfDayIndex: Int(t))
    }
    
    func okButtonPressed(button: UIButton) {
        removeFromSuperview()
        
        let dict = ["dayIndex": selectedDayIndex, "timeIndex": selectedTimeIndex]
        CoreDB.saveSelectedIndexes(dict)
        Device.defaultNotificationCenter().postNotificationName(NOWTIME_CHANGED, object: nil, userInfo: dict)
    }
    
    
    func daysButtonPressed(button: UIButton) {
        selectedDayIndex = button.tag-10
        for btn in daysButtons {
            btn.selected = false
        }
        button.selected = true
        
    }
    
    func timesButtonPressed(button: UIButton) {
        selectedTimeIndex = button.tag-20
        for btn in timesButtons {
            btn.selected = false
        }
        button.selected = true
    }
    
    func selectButtonAtDaysIndex(dayOfWeekIndex: Int, timeOfDayIndex: Int) {
        selectedDayIndex = dayOfWeekIndex
        selectedTimeIndex = timeOfDayIndex
        
        for btn in daysButtons {
            btn.selected = false
        }
        for btn in timesButtons {
            btn.selected = false
        }
        
        daysButtons[dayOfWeekIndex].selected = true
        timesButtons[timeOfDayIndex].selected = true
        
        updateResultLabel(nil)
    }
    
    func closeButtonPressed(button: UIButton) {
        removeFromSuperview()
    }

    func updateResultLabel(result: String?) {
        
        if let _ = result {
            resultLabel.text = result
        }else {
            let dayString = daysButtons[selectedDayIndex].titleLabel!.text
            let timeString = timesButtons[selectedTimeIndex].titleLabel!.text
            resultLabel.text = dayString?.stringByAppendingString("・").stringByAppendingString(timeString!)
        }
    }
   
}

