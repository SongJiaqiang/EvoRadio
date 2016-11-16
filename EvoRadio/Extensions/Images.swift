//
//  Images.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


extension UIImage {
    class func original(_ name: String) -> UIImage {
        return (UIImage(named: name)?.originalImage())!
    }
    
    func originalImage() -> UIImage {
        return self.withRenderingMode(.alwaysOriginal)
    }
    
    class func rectImage(_ color: UIColor, size destSize: CGSize? = nil) -> UIImage {
        let size:CGSize
        if let destSize = destSize {
            size = destSize
        } else {
            size = CGSize(width:1, height: 1)
        }
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        color.setFill()
        ctx?.fill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.resizableImage(withCapInsets: UIEdgeInsets.zero)
    }
    
    class func circleImage(_ color: UIColor, radius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: radius*2, height: radius*2))
        let ctx = UIGraphicsGetCurrentContext()
        color.set()
        ctx?.fillEllipse(in: CGRect(x: 0, y: 0, width: radius*2, height: radius*2))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func resizeImage(_ size: CGSize) -> UIImage {
        var scaleWidth = self.size.width
        var scaleHeight = self.size.height
        if self.size.width > size.width && self.size.height > size.height {
            if self.size.width > self.size.height {
                let scale = size.width / self.size.height
                scaleWidth = self.size.width * scale
                scaleHeight = size.width
            }else {
                let scale = size.width / self.size.width
                scaleWidth = size.width
                scaleHeight = self.size.height * scale
            }
        }
        
        UIGraphicsBeginImageContext(CGSize(width: scaleWidth, height: scaleHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: scaleWidth, height: scaleHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /** 
        压缩图片尺寸到一定内存大小
        memorySize: kb
     */
    func compressImageToLessThan(_ memorySize: Int) -> UIImage {
        if memorySize < 1 {
            return self
        }
        let imageData = UIImageJPEGRepresentation(self, 0.8)
        if imageData?.count < memorySize*1000 {
            return UIImage(data: imageData!)!
        }else {
            _ = UIImage(data: imageData!)?.compressImageToLessThan(memorySize)
        }
        
        return self
    }
    
    func alphaImage(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        ctx?.scaleBy(x: 1, y: -1);
        ctx?.translateBy(x: 0, y: -area.size.height);
        ctx?.setBlendMode(.multiply);
        ctx?.setAlpha(alpha);
        ctx?.draw(self.cgImage!, in: area);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
    }
    
    func scaleToSize(_ size:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    enum ClipImagePosition {
        case begin
        case center
        case end
    }
    
    func clipSquareImage(_ position: ClipImagePosition) -> UIImage {
        
        let interval: CGFloat
        switch position {
        case .begin:
            interval = 0
            break
        case .center:
            interval = (abs(size.height - size.width))*0.5
            break
        case .end:
            interval = abs(size.height - size.width)
            break
        }
        
        var area: CGRect
        if size.width < size.height {
            area = CGRect(x: 0, y: interval, width: size.width, height: size.width);
        }else {
            area = CGRect(x: interval, y: 0, width: size.height, height: size.height);
        }
        let imageRef = self.cgImage?.cropping(to: area)
        let squareImage = UIImage(cgImage: imageRef!)
        return squareImage
    }
    
    func clipSquareImage(_ resizeWidth: CGFloat, position: ClipImagePosition) -> UIImage {
        
        let fixedImage = fixOrientationOfImage()
        
        let interval: CGFloat
        switch position {
        case .begin:
            interval = 0
            break
        case .center:
            interval = (abs(size.height - size.width))*0.5
            break
        case .end:
            interval = abs(size.height - size.width)
            break
        }
        
        var area: CGRect
        if size.width < size.height {
            area = CGRect(x: 0, y: interval, width: size.width, height: size.width);
        }else {
            area = CGRect(x: interval, y: 0, width: size.height, height: size.height);
        }
        let imageRef = fixedImage!.cgImage?.cropping(to: area)
        let squareImage = UIImage(cgImage: imageRef!)
        
        UIGraphicsBeginImageContext(CGSize(width: resizeWidth, height: resizeWidth))
        squareImage.draw(in: CGRect(x: 0, y: 0, width: resizeWidth, height: resizeWidth))
        let resizeSquareImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeSquareImage!
    }
    
    func fixOrientationOfImage() -> UIImage? {
        if imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (self.cgImage?.colorSpace!)!, bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(self.cgImage!, in: CGRect(origin: .zero, size: size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
    
    func writeToFile() -> String!{
        // creating a temp url
        let imageUUID = Foundation.UUID().uuidString
        let imageName = imageUUID + ".jpg"
        
        // default Storage path
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
        
        // storage image
        let data = UIImageJPEGRepresentation(self, 0.9)
        try? data?.write(to: path, options: [.atomic])
        
        return path.path
    }
    
    class func placeholder_cover() -> UIImage {
        return UIImage(named: "placeholder_cover")!
    }
}
