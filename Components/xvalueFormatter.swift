//
//  BarData.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/10/31.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import Charts
public class xvalueFormatter: IAxisValueFormatter{
    var xvalue : [String]!
    init(xvalue: [String]) {
        self.xvalue = xvalue
    }
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (value - floor(value)) == 0{
            return self.xvalue[Int(floor(value)-1)]
        }else{
            return " "
        }
    }
}
