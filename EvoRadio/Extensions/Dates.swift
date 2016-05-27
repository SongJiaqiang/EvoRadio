//
//  Dates.swift
//  EvoRadio
//
//  Created by 宋佳强 on 16/4/27.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation



extension NSDate {
    
    class func getSomeDate(format: NSCalendarUnit) -> Int {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Weekday, .WeekdayOrdinal], fromDate: date)
        
        var value: Int = -1
        switch format {
        case [.Hour]:
            value = components.hour
        case [.Weekday]:
            value = components.weekday
        case [.WeekdayOrdinal]:
            value = components.weekdayOrdinal
        default: break
        }
        return value
    }
    
    class func secondsToMinuteString(seconds: Int) -> String {
        
        if seconds < 0 {
            return "0:00"
        }
        
        let minuteValue = seconds / 60
        let secondValue = seconds % 60
        
        return "\(minuteValue):\(NSString(format: "%02d", secondValue))"
    }
    
}