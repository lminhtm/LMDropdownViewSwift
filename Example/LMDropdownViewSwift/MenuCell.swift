//
//  MenuCell.swift
//  LMDropdownViewSwift_Example
//
//  Created by LMinh on 5/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedMarkView: UIImageView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            titleLabel.backgroundColor = UIColor(red: 81.0/255, green: 168.0/255, blue: 101.0/255, alpha: 1)
        }
        else {
            titleLabel.backgroundColor = UIColor(red: 40.0/255, green: 196.0/255, blue: 80.0/255, alpha: 1)
        }
    }
}
