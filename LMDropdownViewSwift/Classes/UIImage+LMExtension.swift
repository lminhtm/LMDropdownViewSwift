//
//  UIImage+LMExtension.swift
//  LMDropdownViewSwift
//
//  Created by LMinh on 5/14/19.
//

import Foundation
import UIKit
import Accelerate
import CoreGraphics

public extension UIImage {
    
    static func screenshot(fromView view: UIView, size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // -renderInContext: renders in the coordinate space of the layer,
        // so we must first apply the layer's geometry to the graphics context
        context.saveGState()
        
        // Center the context around the window's anchor point
        context.translateBy(x: size.width/2, y: size.height/2)
        
        // Apply the window's transform about the anchor point
        context.concatenate(view.transform)
        
        // Offset by the portion of the bounds left of and above the anchor point
        context.translateBy(x: -view.bounds.size.width * view.layer.anchorPoint.x,
                            y: -view.bounds.size.height * view.layer.anchorPoint.y)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        
        // Restore the context
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func blurred(withRadius radius: CGFloat) -> UIImage {
        
        //image must be nonzero size
        guard floorf(Float(size.width)) * floorf(Float(size.height)) > 0 else { return self }
        
        //boxsize have to be an odd integer
        var boxSize = UInt32(radius * self.scale)
        if boxSize % 2 == 0 {
            boxSize += 1
        }
        
        //create image buffers
        guard let imageRef = self.cgImage else { return self }
        var buffer1 = vImage_Buffer()
        var buffer2 = vImage_Buffer()
        buffer1.width = vImagePixelCount(imageRef.width)
        buffer2.width = vImagePixelCount(imageRef.width)
        buffer1.height = vImagePixelCount(imageRef.height)
        buffer2.height = vImagePixelCount(imageRef.height)
        buffer1.rowBytes = imageRef.bytesPerRow
        buffer2.rowBytes = imageRef.bytesPerRow
        let bytes = buffer1.rowBytes * Int(buffer1.height)
        buffer1.data = malloc(bytes)
        buffer2.data = malloc(bytes)
        
        let tempBuffer = malloc(vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, nil, 0, 0, boxSize, boxSize,
                                                           nil, vImage_Flags(kvImageEdgeExtend + kvImageGetTempBufferSize)))
        
        //copy image data
        let dataSource = imageRef.dataProvider?.data
        memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes)
        
        for _ in 0..<5 {
            //perform blur
            vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, nil, vImage_Flags(kvImageEdgeExtend));
            
            //swap buffers
            let temp = buffer1.data
            buffer1.data = buffer2.data
            buffer2.data = temp
        }
        
        //free buffers
        free(buffer2.data)
        free(tempBuffer)
        
        guard let colorSpace = (imageRef.colorSpace) else {
            return self
        }
        //create image context from buffer
        guard let ctx = CGContext(data: buffer1.data, width: Int(buffer1.width), height: Int(buffer1.height),
                                  bitsPerComponent: 8, bytesPerRow: buffer1.rowBytes, space: colorSpace,
                                  bitmapInfo: imageRef.bitmapInfo.rawValue) else {
                                    return self
        }
        
        guard let imageRef1 = ctx.makeImage() else {
            return self
        }
        let image = UIImage(cgImage: imageRef1, scale: self.scale, orientation: self.imageOrientation)
        
        free(buffer1.data);
        
        return image
    }
}
