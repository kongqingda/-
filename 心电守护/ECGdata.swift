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
    public var dataId : Int32?
    public var isread : Bool
    public var username : String?
    public var samplerate : Int16?
    
    init(date:String,enddate:NSDate,fileurl:String,isupdate:Bool,startdate:NSDate,phone:String,devicename:String?,deviceid:String?,dataId:Int32,isread:Bool,username:String,samplerate : Int16) {
            self.date = date
            self.enddate = enddate
            self.startdate = startdate
            self.fileurl = fileurl
            self.phone = phone
            self.isupdate = isupdate
            self.devicename = devicename
            self.deviceid = deviceid
            self.dataId = dataId
            self.isread = isread
            self.username = username
            self.samplerate = samplerate
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
        self.dataId = 0
        self.isread = false
        self.username = "username"
        self.samplerate = 0
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
        aCoder.encode(dataId, forKey:"dataId")
        aCoder.encode(isread, forKey:"isread")
        aCoder.encode(username, forKey:"username")
        aCoder.encode(samplerate, forKey:"samplerate")

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
        self.dataId = aDecoder.decodeObject(forKey: "dataId") as? Int32
        self.isread = aDecoder.decodeObject(forKey: "isread") as! Bool
        self.username = aDecoder.decodeObject(forKey: "username") as? String
        self.samplerate = aDecoder.decodeObject(forKey: "samplerate") as? Int16
    }

}
