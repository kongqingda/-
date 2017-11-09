//
//  calendarlayout.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/6.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class calendarlayout: UICollectionViewFlowLayout {
   let screenSize  = UIScreen.main.bounds.size;
    var itemheight : CGFloat = 0
    init(itemheight : CGFloat ) {
        super.init()
        self.itemheight = itemheight
        super.itemSize = CGSize(width: (screenSize.width-10)/7, height: itemheight)
  //      super.minimumLineSpacing = 0
        super.minimumInteritemSpacing = 0
//        super.sectionInset = UIEdgeInsetsMake(0, 0, 0.5, 0) //上左下右
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
