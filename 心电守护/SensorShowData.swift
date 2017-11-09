//
//  SensorShowData.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/6.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Charts

class SensorShowData: NSObject {
    var calendar : Calendar!
    var year : Int
    var month : Int
    var day : Int
    var dateFormatter = DateFormatter()
    var calendardataSources: CalendarDataSources!
    override init() {
         let date  = Date()
         calendar = Calendar.init(identifier: .gregorian)     //指定日历的算法
         year = calendar.component(.year, from: date)
         month = calendar.component(.month, from: date)
         day = calendar.component(.day, from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    //数据库获取月数据
    func getmonthdata() -> Array<BarChartDataEntry>{
        calendardataSources = CalendarDataSources.init(year: year, month: month, day: day)
        var monthdata : Array<BarChartDataEntry> = []
        //let result = sensordao.findAll(phone: FirstViewController.phone, style: "month")
        var monthArray : Array<Double> = []
        let datestrArray  = calendardataSources.getNearMonthDate2()
        for datestr in datestrArray{
            let result = SensorDataDao.sharedInstance.findByDate(datestr, FirstViewController.phone)
            if result != nil {
                monthArray.append(Double((result![0] as! Sensordatamodel).stepnum))
            }else{
                monthArray.append(0)
            }
        }
        for j in 0..<30{
            monthdata.append(BarChartDataEntry.init(x: Double(j+1), y: monthArray[j]))
        }
        return monthdata
    }
    //数据库获取周数据
    func getweekdata() -> Array<BarChartDataEntry>{
        calendardataSources = CalendarDataSources.init(year: year, month: month, day: day)
        var weekdata : Array<BarChartDataEntry> = []
        var weekArray : Array<Double> = []
        var datestrArray  = calendardataSources.getNearWeekDate2()
        for i in 0..<7{
            let result = SensorDataDao.sharedInstance.findByDate(datestrArray[i], FirstViewController.phone)
            if result != nil {
                weekArray.append(Double((result![0] as! Sensordatamodel).stepnum))
            }else{
                weekArray.append(0)
            }
        }
        for j in 0..<7{
            weekdata.append(BarChartDataEntry.init(x: Double(j+1), y: weekArray[j]))
        }
        return weekdata
    }
    //获取当天数据
    func gettodaydata() -> (Array<BarChartDataEntry>,Int64){
        calendardataSources = CalendarDataSources.init(year: year, month: month, day: day)
        var daydata : Array<BarChartDataEntry> = []
        var data_today : [UInt8] = []
        var todaydata : [Int64] = []
        var todaystepnum : Int64 = 0
        let datestr  = dateFormatter.string(from: Date())
        let result =  SensorDataDao.sharedInstance.findByDate(datestr, FirstViewController.phone)
        if result != nil{
            let daodata = result![0] as! Sensordatamodel
            todaystepnum = daodata.stepnum
            if daodata.fileurl == "无文件"{
                return (daydata,0)
            }
            data_today = [UInt8](FiledocmDao.init().readfile(filename: daodata.fileurl!)!)
            for i in 0..<240{
                todaydata.append(Int64(CommonUtils.byte2Day(data: [data_today[i*4+0],data_today[i*4+1],data_today[i*4+2],data_today[i*4+3]])))
            }
            for i in 0..<24{
                var ynum : Double = 0
                for j in 0...9{
                    ynum += Double(todaydata[10*i+j])
                }
                daydata.append(BarChartDataEntry.init(x: Double(i+1), y: ynum))
            }
        }else{
            for i in 0..<24{
                daydata.append(BarChartDataEntry.init(x: Double(i+1), y: 0))
            }
        }
        return (daydata,todaystepnum)
        
    }
}
