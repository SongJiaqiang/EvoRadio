//
//  EVReflections.swift
//  EvoRadio
//
//  Created by Jarvis on 5/25/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation
import EVReflection

public extension EVReflection {
    /**
     Return an array representation for the json string
     
     - parameter type: An instance of the type where the array will be created of.
     - parameter json: The json string that will be converted
     - parameter conversionOptions: Option set for the various conversion options.
     
     - returns: The array of dictionaries representation of the json
     */
    public class func objectArrayFromDictionaryArray<T>(_ theObject: NSObject? = nil, type: T, dictArray: [NSDictionary]?, conversionOptions: ConversionOptions = .DefaultDeserialize) -> [T] {
        var result = [T]()
        if dictArray == nil {
            return result
        }
        
        if let jsonDic = dictArray as? [Dictionary<String, AnyObject>]{
            let nsobjectype: NSObject.Type? = T.self as? NSObject.Type
            if nsobjectype == nil {
                debugPrint("WARNING: EVReflection can only be used with types with NSObject as it's minimal base type")
                return result
            }
            
            result = jsonDic.map({
                let nsobject: NSObject = nsobjectype!.init()
                return (setPropertiesfromDictionary($0 as NSDictionary, anyObject: nsobject, conversionOptions: conversionOptions) as? T)!
            })
        }
        
        return result
    }
}

public extension Array where Element: NSObject {
    /**
     Initialize an array based on a dictionary array
     
     - parameter dictArray: The dictionary array
     - parameter conversionOptions: Option set for the various conversion options.
     */
    public init(dictArray: [NSDictionary]?, conversionOptions: ConversionOptions = .DefaultDeserialize) {
        self.init()
        let arrayTypeInstance = getArrayTypeInstance(self)
        let newArray = EVReflection.objectArrayFromDictionaryArray(nil, type: arrayTypeInstance, dictArray: dictArray, conversionOptions: conversionOptions)
        for item in newArray {
            self.append(item)
        }
    }
}

public extension String {
    public func jsonToDictionary() -> NSDictionary {
        let jsonData = self.data(using: String.Encoding.utf8)
        var jsonDict = NSDictionary()
        do {
            jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! NSDictionary
        }catch let error as NSError {
            debugPrint("Convert json data to json dictionary failed with error: \(error)")
        }
        return jsonDict
    }
}

