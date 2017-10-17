//
//  CommonUtils.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/7.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
public class CommonUtils{
    
    static func byte2Year(data : [UInt8]) -> Int32{
        if data.count == 4{
            var tempYear  : Int32 = Int32(data[0])
                + Int32(data[1]) << 8
                + Int32(data[2]) << 16
                + Int32(data[3]) << 24
            tempYear = tempYear > 2000 ? (tempYear)
                : (2000 + tempYear);
            return  tempYear;
        }else {
            return 0
        }
    }
    static func byte2Month(data : [UInt8]) -> Int32{
        if data.count == 4{
            let tempMonth  : Int32 = Int32(data[0])
                + Int32(data[1]) << 8
                + Int32(data[2]) << 16
                + Int32(data[3]) << 24

            
            return  tempMonth;
        }else {
            return 0
        }
    }

    static func byte2Day(data : [UInt8]) -> Int32{
        if data.count == 4{
            let tempDay  : Int32 = Int32(data[0])
                + Int32(data[1]) << 8
                + Int32(data[2]) << 16
                + Int32(data[3]) << 24

            
            return  tempDay;
        }else {
            return 0
        }
    }
    
    static func byte2bigendian(data : [UInt8]) -> Int16{
        if data.count == 4{
            let temp  : Int16 = Int16(data[1])
                + Int16(data[0]) << 8
            return  temp;
        }else {
            return 0
        }

    }
    
    static func copyofRange(data:[UInt8],from:Int,to:Int) ->[UInt8]{
        var result : [UInt8] = []
        for i in from ... to{
            result.append(data[i])
        }
        return result
    }
    static func int2data(num : Int) -> [UInt8]{
        var data : [UInt8] = []
        data = [UInt8((num) & 0xff),UInt8((num >> 8) & 0xff),UInt8((num >> 16) & 0xff),UInt8((num >> 24) & 0xff)]
        return data
    }

    
}
