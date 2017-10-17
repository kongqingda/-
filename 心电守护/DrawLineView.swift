//
//  DrawLineView.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/24.
//  Copyright © 2017年 qingda kong. All rights reserved.
//
import UIKit
enum hand : Int{
    case righthand = 0
    case lefthand = 1
}
class DrawLineView: UIView {
    let widthmax : Int = 2048
    var drawData : Array<Int> = []
    var filterdrawData : Array<Double> = []
    var num : Int = 1
    let heightmax : Int = 3072
    let m : Double = 0.143
    let fiternum : Int = 10
    var viewwidth : CGFloat = 0
    var viewheight : CGFloat = 0
    var zhengyi : Double = 10 //增益值
    var scale : Double = 10
    static var myhand : hand = hand.lefthand

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //填充白色背景
        viewwidth = rect.size.width
        
        viewheight = rect.size.height
        
         let context = UIGraphicsGetCurrentContext()
         context!.scaleBy(x: 1, y: -1)
         context!.translateBy(x: 0, y: -viewheight)

        //绘制曲线
        filterdrawData = filterdata(filternum: fiternum,data: drawData)
        let per_w = Double(viewwidth)/Double(widthmax)
        //let per_h = Double(viewheight)/Double(heightmax)
        context!.setLineWidth(1.2)
        context!.move(to: CGPoint(x:0,y:viewheight/2))
        if drawData.count > 0 {
            var i : Double = 1
            for data in filterdrawData{
                context!.addLine(to: CGPoint(x:per_w * i,y:data+Double(viewheight)/2))
                i += 1
            }
        }
        //设置线条颜色
        UIColor.init(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).setStroke()
        context!.drawPath(using: .stroke)
        
        
    }
    func turnData(data : Int) -> Double {
        var result : Double = (Double(data)*m)/1000
        result = -(result*zhengyi*(55/Double(viewheight))*scale)
        if DrawLineView.myhand == hand.righthand{
            return result
        }else {
            return -result
        }
       // return result
        
    }
    //均值滤波算法
    func filterdata(filternum : Int, data : Array<Int>) -> Array<Double>{
        var result : Array<Double> = []
        var sumdata : Double = 0
        var mean : Double = 0
        for i in 0..<data.count{
            sumdata = 0
            if i<(filternum-1){
                for j in 0...i{
                    sumdata += turnData(data: data[j])
                }
                mean = Double(i+1)
            }else{
                for j in (i-filternum+1)...i{
                    sumdata += turnData(data: data[j])
                }
                mean = Double(filternum)
            }
            result.append(Double(sumdata/mean))
        }
             return result
    }
    
 

}
