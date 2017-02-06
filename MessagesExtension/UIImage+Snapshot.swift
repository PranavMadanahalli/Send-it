//
//  UIImage+Snapshot.swift
//  Send it
//
//  Created by Pranav Madanahalli on 2/4/17.
//  Copyright © 2017 Pranav Madanahalli. All rights reserved.
//

import UIKit

extension UIImage {
    /// Create an image represenation of the given view
    class func snapshot(from view: UITextView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return snapshot!
    }
}
