//
//  Images.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

extension UIImage {
    static func original(name: String) -> UIImage {
        return (UIImage(named: name)?.originalImage())!
    }
    
    func originalImage() -> UIImage {
        return self.imageWithRenderingMode(.AlwaysOriginal)
    }
    
    static func rectImage(color: UIColor, size destSize: CGSize? = nil) -> UIImage {
        let size:CGSize
        if let destSize = destSize {
            size = destSize
        } else {
            size = CGSize(width:1, height: 1)
        }
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        color.setFill()
        CGContextFillRect(ctx, CGRect(origin: CGPointZero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image.resizableImageWithCapInsets(UIEdgeInsetsZero)
    }
    
    static func circleImage(color: UIColor, radius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(radius*2, radius*2))
        let ctx = UIGraphicsGetCurrentContext()
        color.set()
        CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, radius*2, radius*2))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizeImage(size: CGSize) -> UIImage {
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
        
        UIGraphicsBeginImageContext(CGSizeMake(scaleWidth, scaleHeight))
        self.drawInRect(CGRectMake(0, 0, scaleWidth, scaleHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func alphaImage(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        CGContextSetBlendMode(ctx, .Multiply);
        CGContextSetAlpha(ctx, alpha);
        CGContextDrawImage(ctx, area, self.CGImage);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func scaleToSize(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    enum ClipImagePosition {
        case Begin
        case Center
        case End
    }
    
    func clipSquareImage(position: ClipImagePosition) -> UIImage {
        
        let interval: CGFloat
        switch position {
        case .Begin:
            interval = 0
            break
        case .Center:
            interval = (abs(size.height - size.width))*0.5
            break
        case .End:
            interval = abs(size.height - size.width)
            break
        }
        
        var area: CGRect
        if size.width < size.height {
            area = CGRectMake(0, interval, size.width, size.width);
        }else {
            area = CGRectMake(interval, 0, size.height, size.height);
        }
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, area)
        let squareImage = UIImage(CGImage: imageRef!)
        return squareImage
    }
    
    func clipSquareImage(resizeWidth: CGFloat, position: ClipImagePosition) -> UIImage {
        
        let fixedImage = fixOrientationOfImage()
        
        let interval: CGFloat
        switch position {
        case .Begin:
            interval = 0
            break
        case .Center:
            interval = (abs(size.height - size.width))*0.5
            break
        case .End:
            interval = abs(size.height - size.width)
            break
        }
        
        var area: CGRect
        if size.width < size.height {
            area = CGRectMake(0, interval, size.width, size.width);
        }else {
            area = CGRectMake(interval, 0, size.height, size.height);
        }
        let imageRef = CGImageCreateWithImageInRect(fixedImage!.CGImage, area)
        let squareImage = UIImage(CGImage: imageRef!)
        
        UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeWidth))
        squareImage.drawInRect(CGRectMake(0, 0, resizeWidth, resizeWidth))
        let resizeSquareImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeSquareImage
    }
    
    func fixOrientationOfImage() -> UIImage? {
        if imageOrientation == .Up {
            return self
        }
        
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
        default:
            break
        }
        
        switch imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        
        guard let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue) else {
            return nil
        }
        
        CGContextConcatCTM(context, transform)
        
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            CGContextDrawImage(context, CGRect(x: 0, y: 0, width: size.height, height: size.width), CGImage)
        default:
            CGContextDrawImage(context, CGRect(origin: .zero, size: size), self.CGImage)
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = CGBitmapContextCreateImage(context) else {
            return nil
        }
        
        return UIImage(CGImage: CGImage)
    }
    
    func writeToFile() -> String!{
        // creating a temp url
        let imageUUID = NSUUID().UUIDString
        let imageName = imageUUID.stringByAppendingString(".jpg")
        
        // default Storage path
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(imageName)
        
        // storage image
        let data = UIImageJPEGRepresentation(self, 0.9)
        data?.writeToURL(path, atomically: true)
        
        return path.path
    }
    
    class func placeholder_cover() -> UIImage {
        return UIImage(named: "placeholder_cover")!
    }
}
