//
//  CalendarDataSources.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/4.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
public class CalendarDataSources{
    var year : Int
    var month : Int
    var day : Int
    init(year : Int,month : Int) {
        self.year = year
        self.month = month
        self.day = 1
    }
    init(year : Int,month : Int,day:Int) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    //获取一个月的总天数
    func getMonthDays() -> Int{
        let calendar : Calendar = Calendar.init(identifier: .gregorian)     //指定日历的算法
        let date : Date = toDate()
        let range : Range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    //每月1号是周几
    func getWeekDaywithDate()  -> Int{
        let date : Date = toDate()
        let calendar : Calendar = Calendar.init(identifier: .gregorian)     //指定日历的算法
        let week : Int = calendar.component(.weekday, from: date)
        // 1 是周日，2是周一 3.以此类推
        print("周\(week)")
        return week
    }
    
    //转化为日期
    func toDate() -> Date {
        let dateformatter : DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let str_year = NSString(format: "%04ld", year)
        let str_month = NSString(format: "%02ld", month)
        let str_day = NSString(format: "%02ld", day)
        let format_date = NSString(format: "%@-%@-%@",str_year,str_month,str_day)
        let date : Date = dateformatter.date(from: format_date as String)!
        return date
    }
}
