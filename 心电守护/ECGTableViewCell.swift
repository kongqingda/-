//
//  ECGTableViewCell.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class ECGTableViewCell: UITableViewCell {

    @IBOutlet weak var maclabel: UILabel!
    @IBOutlet weak var enddatelabel: UILabel!
    @IBOutlet weak var startdatelabel: UILabel!
    @IBOutlet weak var devicename: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //maclabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
                
        // Configure the view for the selected state
    }

}
