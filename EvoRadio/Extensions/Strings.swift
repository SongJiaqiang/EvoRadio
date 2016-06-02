//
//  Strings.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

extension String {
    
    func lastPathComponent() -> String {
        return NSURL(string: self)!.lastPathComponent!
    }
    
    func appendPathComponent(component: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(component)
    }
    
    func appendPathComponents(components: [String]) -> String {
        
        let newPath = (self as NSString)
        for comp in components {
            newPath.stringByAppendingPathComponent(comp)
        }
        
        return newPath as String
    }
    
}