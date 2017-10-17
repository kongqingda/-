//
//  ECGmsgmodel.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class ECGdata: NSObject {

     public var date: String?
     public var enddate: NSDate?
     public var fileurl: String?
     public var isupdate: Bool
     public var startdate: NSDate?
     public var phone: String?
    public var devicename: String?
    public var deviceid: String?
    
    
    init(date:String,enddate:NSDate,fileurl:String,isupdate:Bool,startdate:NSDate,phone:String,devicename:String?,deviceid:String?) {
        self.date = date
        self.enddate = enddate
        self.startdate = startdate
        self.fileurl = fileurl
        self.phone = phone
        self.isupdate = isupdate
        self.devicename = devicename
        self.deviceid = deviceid
    
    }
    
    override init() {
        self.date = ""
        self.enddate = NSDate()
        self.startdate = NSDate()
        self.fileurl = ""
        self.phone = ""
        self.isupdate = false
        self.devicename = "TH"
        self.deviceid = ""
    }
    // MARK: --实现NSCoding协议
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey:"date")
        aCoder.encode(enddate, forKey:"enddate")
        aCoder.encode(startdate, forKey:"startdate")
        aCoder.encode(fileurl, forKey:"fileurl")
        aCoder.encode(phone, forKey:"phone")
        aCoder.encode(isupdate, forKey:"isupdate")
        aCoder.encode(devicename, forKey:"devicename")
        aCoder.encode(deviceid, forKey:"deviceid")
    }
    public required init(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as? String
        self.enddate = aDecoder.decodeObject(forKey: "enddate") as? NSDate
        self.startdate = aDecoder.decodeObject(forKey: "startdate") as? NSDate
        self.fileurl = aDecoder.decodeObject(forKey: "fileurl") as? String
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String
        self.isupdate = aDecoder.decodeObject(forKey: "isupdate") as! Bool
        self.devicename = aDecoder.decodeObject(forKey: "devicename") as? String
        self.deviceid = aDecoder.decodeObject(forKey: "deviceid") as? String
    }

}
