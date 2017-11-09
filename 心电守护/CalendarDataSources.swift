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
    //获取临近30天的日期
    func getNearMonthDate() -> Array<String>{
        var monthdate : Array<String> = []
        var mm = month
        var dd = day+1
        for i in 0..<30{
            dd = dd - 1
            if dd == 0{
                mm = mm - 1
                if mm == 0{
                    mm = 12
                }
                month  = mm
                dd = getMonthDays()
            }
            let datestr = String.init(format: "%02ld/%02ld", mm,dd)
            monthdate.append(datestr)
        }
        return monthdate.reversed()
    }
    //获取临近30天的日期
    func getNearMonthDate2() -> Array<String>{
        var monthdate : Array<String> = []
        var yy = year
        var mm = month
        var dd = day+1
        for i in 0..<30{
            dd = dd - 1
            if dd == 0{
                mm = mm - 1
                if mm == 0{
                    mm = 12
                    yy -= 1
                }
                year = yy
                month  = mm
                dd = getMonthDays()
            }
            let datestr = String.init(format: "%d-%02ld-%02ld", yy,mm,dd)
            monthdate.append(datestr)
        }
        return monthdate.reversed()
    }
    //获取今天的时刻
    func getTodayDate() -> Array<String>{
         var todaydate : Array<String> = []
        for i in 0..<24{
            todaydate.append(String.init(format: "%i:00", i))
        }
        return todaydate
    }
    
    //获取临近一周的日期
    func getNearWeekDate() -> Array<String>{
        var weekdate : Array<String> = []
       
        let date : Date = Date()
        var datestr : String!
        let calendar : Calendar = Calendar.init(identifier: .gregorian)     //指定日历的算法
        var week : Int = calendar.component(.weekday, from: date)
        for _ in 0..<7{
            
            if week == 0{
                week = 7
            }
            switch week{
            case 1:
                datestr = "周日"
            case 2:
                datestr = "周一"
            case 3:
                datestr = "周二"
            case 4:
                datestr = "周三"
            case 5:
                datestr = "周四"
            case 6:
                datestr = "周五"
            case 7:
                datestr = "周六"
            default:
                break
            }
            weekdate.append(datestr)
            week = week - 1
        }
       
        return weekdate.reversed()
    }
    func getNearWeekDate2() -> Array<String>{
        var weekdate : Array<String> = []
        var yy = year
        var mm = month
        var dd = day+1
        for _ in 0..<7{
            dd = dd - 1
            if dd == 0{
                mm = mm - 1
                if mm == 0{
                    mm = 12
                    yy -= 1
                }
                year = yy
                month  = mm
                dd = getMonthDays()
            }
            let datestr = String.init(format: "%d-%02ld-%02ld", yy,mm,dd)
            weekdate.append(datestr)
        }
        return weekdate.reversed()
        
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
