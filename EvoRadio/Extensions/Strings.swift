//
//  Strings.swift
//  EvoRadio
//
//  Created by Jarvis on 6/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

extension String {
    
    func lastPathComponent() -> String {
        return NSURL(string: self)!.lastPathComponent!
    }
    
    func appendPathComponent(component: String) -> String {
        return self.stringByAppendingString("/").stringByAppendingString(component)
    }
    
    func appendPathComponents(components: [String]) -> String {
        
        var newPath: String = self
        for comp in components {
            newPath = newPath.stringByAppendingString("/").stringByAppendingString(comp)
        }
        
        return newPath
    }
    
}