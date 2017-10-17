//
//  ECGData.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

public class ECGmsg: NSObject , NSCoding {
     public var datanum: Int16
     public var date: String?
     public var deviceid: String?
     public var mac: String?
     public var phone: String
    
   init(date:String,datanum:Int16,deviceid:String,mac:String,phone:String) {
        self.date = date
        self.datanum = datanum
        self.deviceid = deviceid
        self.mac = mac
        self.phone = phone
    }

    override init() {
        self.date = String()
        self.datanum = 0
        self.deviceid = ""
        self.mac = ""
        self.phone = ""
    }
         // MARK: --实现NSCoding协议
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey:"date")
        aCoder.encode(datanum, forKey:"datanum")
        aCoder.encode(deviceid, forKey:"deviceid")
        aCoder.encode(mac, forKey:"mac")
        aCoder.encode(phone, forKey:"phone")
    }
    public required init(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as? String
        self.datanum = aDecoder.decodeObject(forKey: "datanum") as! Int16
        self.deviceid = aDecoder.decodeObject(forKey: "deviceid") as? String
        self.mac = aDecoder.decodeObject(forKey: "mac") as? String
        self.phone = aDecoder.decodeObject(forKey: "phone") as! String
    }


}
