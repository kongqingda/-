//
//  CalendarCell.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/2.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet weak var date: UIButton!
    @IBOutlet weak var redsign: UIImageView!
    @IBOutlet weak var celllabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func select(_ sender: Any?) {
        celllabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
}
