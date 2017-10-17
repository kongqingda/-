//
//  calenderbackview.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/10/13.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class calenderbackview: UICollectionView {

   
    var viewwidth : CGFloat = 0
    var viewheight : CGFloat = 0
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //填充白色背景
        viewwidth = rect.size.width
        
        viewheight = rect.size.height
        
        UIColor.white.setFill()
        UIRectFill(rect)
        let context = UIGraphicsGetCurrentContext()
        context!.scaleBy(x: 1, y: -1)
        context!.translateBy(x: 0, y: -viewheight)
        //绘制背景
        let y : Int = 5
        let x : Int = 1
        let n : Int = 1
        
        let jianh = viewheight/(CGFloat(y*n))
        let jianw = viewwidth/(CGFloat(x*n))
    
        for h in 0 ..< y+1 {
            context!.move(to: CGPoint(x:0,y:jianh * CGFloat(h)))
            context!.addLine(to: CGPoint(x:viewwidth,y:jianh * CGFloat(h)))
        }
        for h in 0 ..< x+1 {
            context!.move(to: CGPoint(x:jianw * CGFloat(h),y:0))
            context!.addLine(to: CGPoint(x:jianw * CGFloat(h),y:viewheight))
        }
        context!.setLineWidth(0.2)
        UIColor.init(cgColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)).setStroke()
        context!.drawPath(using: .stroke)
        
    }
    
    
}

