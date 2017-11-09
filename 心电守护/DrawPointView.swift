//
//  DrawPointView.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/8.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class DrawPointView: UIView {
    var widthmax : Int = 512*4
    var drawData : Array<Double> = []
    var filterdrawData : Array<Double> = []
    var num : Int = 1
    let heightmax : Int = 3072
    let m : Double = 0.143
    let filternum : Int = 0 //滤波参数
    var viewwidth : CGFloat = 0
    var viewheight : CGFloat = 0
    var zhengyi : Double = 10 //增益值
    var scale : Double = 10
    var beforenum : Double = 0
    var per_w : Double = 0
    var drawnum : Double = 0
    var linelength : Double = 40
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //填充白色背景
        viewwidth = rect.size.width
        
        viewheight = rect.size.height
        
//        let context = UIGraphicsGetCurrentContext()
//        context!.scaleBy(x: 1, y: -1)
//        context!.translateBy(x: 0, y: -viewheight)
//
//        //绘制曲线
//        per_w = Double(viewwidth)/Double(widthmax)
//        context!.setLineWidth(1.5)
//        context!.move(to: CGPoint(x:0,y:viewheight/2))
//        if drawData.count > 0 {
//            var i : Double = 1
//            for data in filterdrawData{
//                context!.addLine(to: CGPoint(x:per_w * i,y:(data*Double(viewheight))/110+Double(viewheight)/2))
//                i += 1
//            }
//        }
//        //设置线条颜色
//        UIColor.init(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).setStroke()
//        context!.drawPath(using: .stroke)
//          context?.setStrokeColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        
    }
    override func draw(_ layer: CALayer, in ctx: CGContext) {
       
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -viewheight)
        
        //绘制曲线
        
        ctx.setLineWidth(1.5)
        ctx.move(to: CGPoint(x:0,y:viewheight/2))
//        if drawData.count > 0 {
//            var i : Double = 1
//            for data in filterdrawData{
//                ctx.addLine(to: CGPoint(x:per_w * i,y:(data*Double(viewheight))/110+Double(viewheight)/2))
//                i += 1
//            }
//        }
//        if drawnum>1{
//            if filterdrawData.count > 1{
//                ctx.addLines(between: [CGPoint(x:per_w * (drawnum-1),y:(filterdrawData[Int(drawnum-2)]*Double(viewheight))/110+Double(viewheight)/2),
//                                       CGPoint(x:per_w * (drawnum),y:(filterdrawData[Int(drawnum-1)]*Double(viewheight))/110+Double(viewheight)/2)])
//                //ctx.move(to: CGPoint(x:per_w * (drawnum-1),y:(filterdrawData[Int(drawnum-2)]*Double(viewheight))/110+Double(viewheight)/2))
//                //ctx.addLine(to: CGPoint(x:per_w * (drawnum),y:(filterdrawData[Int(drawnum-1)]*Double(viewheight))/110+Double(viewheight)/2))
//            }else{
//                drawnum = 0
//            }
//
//        }
        
        if drawData.count >= Int(linelength){
           // ctx.move(to: CGPoint(x:per_w * (drawnum-10),y:(filterdrawData[Int(drawnum-10)]*Double(viewheight))/110+Double(viewheight)/2))
            for n in -1..<Int(linelength){
                ctx.addLine(to: CGPoint(x:per_w * (drawnum-linelength+Double(n)),y:(filterdrawData[Int(drawnum-linelength+Double(n))]*Double(viewheight))/110+Double(viewheight)/2))
            }
        }
        
        //设置线条颜色
         UIColor.init(cgColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)).setStroke()
        ctx.setStrokeColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        ctx.drawPath(using: .stroke)
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
    
    func adddata(perdata : Int?){
        if perdata != nil{
            drawData.append(self.turnData(data: perdata!))
            if drawData.count > widthmax{
                drawData.removeAll()
                drawData.append(self.turnData(data: perdata!))
                self.layer.setNeedsDisplay()
            }
            filterdrawData = filterdata(filternum: filternum, data: drawData)
            let x : CGFloat = (self.frame.width)*CGFloat(filterdrawData.count-2)/CGFloat(widthmax)
            //let aftertime = TimeInterval(1/Double(FirstViewController.SAMPLERATE))
            let i = Double(drawData.count-1)
            if (drawData.count-1)%Int(linelength) == 0{
                self.drawline()
            }
            //self.setNeedsDisplay(CGRect.init(x:per_w * i,y:0.0, width:per_w*2, height: Double(self.frame.height)))
            // self.perform(#selector(drawline), with: nil, afterDelay:aftertime )
        }else{
            filterdrawData = filterdata(filternum: filternum, data: drawData)
            self.layer.setNeedsDisplay()
        }
        
    }
    func drawline(){
        viewwidth = self.frame.width
        viewheight = self.frame.height
        per_w = Double(viewwidth)/Double(widthmax)
        drawnum = Double(drawData.count)
        self.layer.setNeedsDisplayIn(CGRect.init(x:per_w * Double(drawnum-linelength),y:0.0, width:per_w*(linelength+1), height: Double(self.frame.height)))
    }
    
    //均值滤波算法
    func filterdata(filternum : Int, data : Array<Double>) -> Array<Double>{
        var result : Array<Double> = []
        var sumdata : Double = 0
        var mean : Double = 0
        if filternum == 0{
            return data
        }else{
            for i in 0..<data.count{
                sumdata = 0
                if i<(filternum-1){
                    for j in 0...i{
                        sumdata += data[j]
                    }
                    mean = Double(i+1)
                }else{
                    for j in (i-filternum+1)...i{
                        sumdata += data[j]
                    }
                    mean = Double(filternum)
                }
                result.append(Double(sumdata/mean))
            }
            return result
        }
        
    }
    
    
    
}

