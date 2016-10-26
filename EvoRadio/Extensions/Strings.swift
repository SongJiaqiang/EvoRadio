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
        return URL(string: self)!.lastPathComponent
    }
    
    func appendPathComponent(_ component: String) -> String {
        return (self + "/") + component
    }
    
    func appendPathComponents(_ components: [String]) -> String {
        
        var newPath: String = self
        for comp in components {
            newPath = (newPath + "/") + comp
        }
        
        return newPath
    }
    
}
