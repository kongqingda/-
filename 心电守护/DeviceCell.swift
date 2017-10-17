//
//  DeviceCell.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/11.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var devicename: UILabel!
    @IBOutlet weak var devicerssi: UILabel!
    @IBOutlet weak var deviceicon: UIImageView!
    @IBOutlet weak var selectimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true{
            selectimage.image = UIImage(named: "已选中.png")
        }else{
            selectimage.image = UIImage(named: "未选中.png")
        }

        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
