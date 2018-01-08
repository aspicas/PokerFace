//
//  UIImageView+ContentClippingRect.swift
//  PokerFace
//
//  Created by David Garcia on 1/8/18.
//  Copyright © 2018 David Garcia. All rights reserved.
//

import UIKit

extension UIImageView {
    
    var contentClippingRect: CGRect {
        guard let image = image, contentMode == .scaleAspectFit else { return bounds }
        let imageWith = image.size.width
        let imageHeight = image.size.height
        
        guard imageWith > 0 && imageHeight > 0 else { return bounds }
        
        let scale: CGFloat
        if imageWith > imageHeight {
            scale = bounds.size.width / imageWith
        } else {
            scale = bounds.size.height / imageHeight
        }
        
        let clippingSize = CGSize(width: imageWith * scale, height: imageHeight * scale)
        let x = (bounds.size.width - clippingSize.width) / 2.0
        let y = (bounds.size.height - clippingSize.height) / 2.0
        
        return CGRect(origin: CGPoint(x: x, y: y), size: clippingSize)
    }
}
