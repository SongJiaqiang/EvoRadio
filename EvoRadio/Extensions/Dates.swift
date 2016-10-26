//
//  Dates.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/27.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation



extension Date {
    
    static func getSomeDate(_ format: NSCalendar.Unit) -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .weekday, .weekdayOrdinal], from: date)
        
        var value: Int = -1
        switch format {
        case [.hour]:
            value = components.hour!
        case [.weekday]:
            value = components.weekday!
        case [.weekdayOrdinal]:
            value = components.weekdayOrdinal!
        default: break
        }
        return value
    }
    
    static func secondsToMinuteString(_ seconds: Int) -> String {
        
        if seconds < 0 {
            return "0:00"
        }
        
        let minuteValue = seconds / 60
        let secondValue = seconds % 60
        
        return "\(minuteValue):\(NSString(format: "%02d", secondValue))"
    }
    
}
