//
//  Sensordatamodel.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/12.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class Sensordatamodel: NSObject ,NSCoding{
     public var phone: String?
     public var date: String?
     public var deviceid: String?
     public var fileurl: String?
     public var isupdate: Bool
    public var stepnum: Int64
    
    
    init(date:String,fileurl:String,isupdate:Bool,phone:String,deviceid:String?,stepnum: Int64) {
        self.date = date
        self.fileurl = fileurl
        self.phone = phone
        self.isupdate = isupdate
        self.deviceid = deviceid
        self.stepnum = stepnum
        
    }
    
    override init() {
        self.date = ""
        self.fileurl = ""
        self.phone = ""
        self.isupdate = false
        self.deviceid = ""
        self.stepnum = 0
    }
    // MARK: --实现NSCoding协议
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey:"date")
        aCoder.encode(fileurl, forKey:"fileurl")
        aCoder.encode(phone, forKey:"phone")
        aCoder.encode(isupdate, forKey:"isupdate")
        aCoder.encode(deviceid, forKey:"deviceid")
         aCoder.encode(deviceid, forKey:"stepnum")
    }
    public required init(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as? String
        self.fileurl = aDecoder.decodeObject(forKey: "fileurl") as? String
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String
        self.isupdate = aDecoder.decodeObject(forKey: "isupdate") as! Bool
        self.deviceid = aDecoder.decodeObject(forKey: "deviceid") as? String
         self.stepnum = (aDecoder.decodeObject(forKey: "stepnum") as? Int64)!
    }

}
