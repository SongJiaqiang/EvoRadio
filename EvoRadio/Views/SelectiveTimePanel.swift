//
//  SelectiveTimePanel.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/27.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class SelectiveTimePanel: UIView {
    fileprivate var weekView = UIView()
    fileprivate let nowButton = UIButton()
    fileprivate let okButton = UIButton()
    fileprivate let randomButton = UIButton()
    fileprivate let resultLabel = UILabel()
    let backgroundView = UIView()
    
    var daysButtons = [UIButton]()
    var timesButtons = [UIButton]()
    
    var selectedDayIndex: Int = 0
    var selectedTimeIndex: Int = 0
    
    public static let timePanel = SelectiveTimePanel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()

        if let indexes = CoreDB.getSelectedIndexes() {
            selectButtonAtDaysIndex(indexes["dayIndex"]!, timeOfDayIndex: indexes["timeIndex"]!)
        }else {
            nowButtonPressed(nowButton)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        
        prepareBackgroundView()
        prepareBottomButtons()
        prepareWeekCollectionView()
        
    }
    
    func prepareBackgroundView() {
        
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        backgroundView.alpha = 0.8
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(netHex: 0x2F0189).cgColor,
                                UIColor(netHex: 0xB300C2).cgColor,
                                UIColor(netHex: 0x1347DE).cgColor,
                                UIColor(netHex: 0x3CE5D8).cgColor,
                                UIColor(netHex: 0x309D69).cgColor,
                                UIColor(netHex: 0xEBEF00).cgColor]
        gradientLayer.locations = [0, 0.15,0.4,0.6,0.85, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = Device.keyWindow().bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }

    func prepareBottomButtons() {
        
        addSubview(nowButton)
        nowButton.titleLabel?.font = UIFont.size14()
        nowButton.titleLabel?.textColor = UIColor.white
        nowButton.setTitle("当前时刻", for: .normal)
        nowButton.backgroundColor = UIColor.grayColor28()
        nowButton.addTarget(self, action: #selector(SelectiveTimePanel.nowButtonPressed(_:)), for: .touchUpInside)
        
        addSubview(okButton)
        okButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        okButton.titleLabel?.textColor = UIColor.white
        okButton.setTitle("确定", for: .normal)
        okButton.backgroundColor = UIColor.goldColor()
        okButton.addTarget(self, action: #selector(SelectiveTimePanel.okButtonPressed(_:)), for: .touchUpInside)
        
        addSubview(randomButton)
        randomButton.titleLabel?.font = UIFont.size14()
        randomButton.titleLabel?.textColor = UIColor.white
        randomButton.setTitle("随机时刻", for: .normal)
        randomButton.backgroundColor = UIColor.grayColor28()
        randomButton.addTarget(self, action: #selector(SelectiveTimePanel.randomButtonPressed(_:)), for: .touchUpInside)
        
        let buttonHeight: CGFloat = playerBarHeight
        nowButton.snp.makeConstraints { (make) in
            make.height.equalTo(buttonHeight)
            make.leftMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
            make.right.equalTo(okButton.snp.left)
            make.width.equalTo(okButton)
        }
        
        randomButton.snp.makeConstraints { (make) in
            make.height.equalTo(buttonHeight)
            make.rightMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(okButton.snp.right)
            make.width.equalTo(okButton)
        }
        
        okButton.snp.makeConstraints { (make) in
            make.height.equalTo(buttonHeight)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(nowButton.snp.right)
            make.right.equalTo(randomButton.snp.left)
            make.width.equalTo(randomButton)
        }
        
        nowButton.alpha = 0.9
        randomButton.alpha = 0.9
        okButton.alpha = 0.9
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
        weekView.snp.makeConstraints { (make) in
            make.center.equalTo(snp.center)
            make.height.equalTo(height)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        addSubview(resultLabel)
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.size16()
        resultLabel.textColor = UIColor.white
        resultLabel.text = "星期一 ▪ 清晨"
        resultLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(weekView.snp.top).offset(-30)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        let daysContentView = UIView()
        addSubview(daysContentView)
        
        let timesContentView = UIView()
        addSubview(timesContentView)
        
        daysContentView.snp.makeConstraints { (make) in
            make.height.equalTo(contentHeight)
            make.centerY.equalTo(snp.centerY)
            make.leftMargin.equalTo(0)
            make.right.equalTo(timesContentView.snp.left)
            make.width.equalTo(timesContentView.snp.width)
        }
        timesContentView.snp.makeConstraints { (make) in
            make.height.equalTo(contentHeight)
            make.centerY.equalTo(snp.centerY)
            make.left.equalTo(daysContentView.snp.right)
            make.rightMargin.equalTo(0)
            make.width.equalTo(timesContentView.snp.width)
        }
        
        for i in 0..<daysCount {
            let button = UIButton()
            button.titleLabel?.font = UIFont.size12()
            button.titleLabel?.textColor = UIColor.white
            button.setTitle(daysOfWeek[i], for: .normal)
            button.clipsToBounds = true
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.setBackgroundImage(UIImage.rectImage(UIColor(white: 1, alpha: 0.5)), for: .highlighted)
            button.setBackgroundImage(UIImage.rectImage(UIColor.grayColor28()), for: .selected)
            button.addTarget(self, action: #selector(SelectiveTimePanel.daysButtonPressed(_:)), for: .touchUpInside)
            button.tag = 10+i
            daysContentView.addSubview(button)
            daysButtons.append(button)
            
            button.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: buttonwidth, height: buttonHeight))
                make.centerX.equalTo(daysContentView.snp.centerX)
                make.topMargin.equalTo((buttonHeight+margin)*CGFloat(i))
            })
            
        }
        
        for i in 0..<timesCount {
            let button = UIButton()
            button.titleLabel?.font = UIFont.size12()
            button.titleLabel?.textColor = UIColor.white
            button.setTitle(timesOfDay[i], for: .normal)
            button.clipsToBounds = true
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.setBackgroundImage(UIImage.rectImage(UIColor(white: 1, alpha: 0.5)), for: .highlighted)
            button.setBackgroundImage(UIImage.rectImage(UIColor.grayColor28()), for: .selected)
            button.addTarget(self, action: #selector(SelectiveTimePanel.timesButtonPressed(_:)), for: .touchUpInside)
            button.tag = 20+i
            timesContentView.addSubview(button)
            timesButtons.append(button)
            
            button.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: buttonwidth, height: buttonHeight))
                make.centerX.equalTo(timesContentView.snp.centerX)
                make.topMargin.equalTo((buttonHeight+margin)*CGFloat(i))
            })
            
        }
        
    }

    //MARK: event
    @objc func nowButtonPressed(_ button: UIButton) {
        selectButtonAtDaysIndex(CoreDB.currentDayOfWeek(), timeOfDayIndex: CoreDB.currentTimeOfDay())
    }
    
    @objc func randomButtonPressed(_ button: UIButton) {
        let d = arc4random_uniform(7)
        let t = arc4random_uniform(8)
        selectButtonAtDaysIndex(Int(d), timeOfDayIndex: Int(t))
    }
    
    @objc func okButtonPressed(_ button: UIButton) {
//        removeFromSuperview()

        hide()
        
        let dict = ["dayIndex": selectedDayIndex, "timeIndex": selectedTimeIndex]
        CoreDB.saveSelectedIndexes(dict)
        NotificationCenter.default.post(name: NOTI_NOWTIME_CHANGED, object: nil, userInfo: dict)
    }
    
    
    @objc func daysButtonPressed(_ button: UIButton) {
        selectedDayIndex = button.tag-10
        for btn in daysButtons {
            btn.isSelected = false
        }
        button.isSelected = true
        
    }
    
    @objc func timesButtonPressed(_ button: UIButton) {
        selectedTimeIndex = button.tag-20
        for btn in timesButtons {
            btn.isSelected = false
        }
        button.isSelected = true
    }
    
    func selectButtonAtDaysIndex(_ dayOfWeekIndex: Int, timeOfDayIndex: Int) {
        selectedDayIndex = dayOfWeekIndex
        selectedTimeIndex = timeOfDayIndex
        
        for btn in daysButtons {
            btn.isSelected = false
        }
        for btn in timesButtons {
            btn.isSelected = false
        }
        
        daysButtons[dayOfWeekIndex].isSelected = true
        timesButtons[timeOfDayIndex].isSelected = true
        
        updateResultLabel(nil)
    }
    

    func updateResultLabel(_ result: String?) {
        
        if let _ = result {
            resultLabel.text = result
        }else {
            let dayString = daysButtons[selectedDayIndex].titleLabel!.text
            let timeString = timesButtons[selectedTimeIndex].titleLabel!.text
            resultLabel.text = (dayString! + "・") + timeString!
        }
    }
   
    public func show() {
        Device.keyWindow().addSubview(self)
        self.alpha = 0
        self.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }, completion: { completion in
            self.removeFromSuperview()
        })
    }
}

