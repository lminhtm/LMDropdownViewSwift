//
//  NavigationController.swift
//  LMDropdownViewSwift_Example
//
//  Created by LMinh on 5/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
        navigationBar.tintColor = .white
        
        let lineView = UIView(frame: CGRect(x: 0,
                                            y: navigationBar.bounds.size.height - 2,
                                            width: navigationBar.bounds.size.width,
                                            height: 2))
        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        lineView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        navigationBar.addSubview(lineView)
        navigationBar.bringSubviewToFront(lineView)
    }
}
