//
//  Usermsg.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/8.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class Usermsgmodel: NSObject, NSCoding {
    
    
     public var phone: String?
     public var bindper: String?
     public var bindmac: String?
     public var binddate: String?
     public var bindname: String?
    
    init(phone:String,bindper:String,bindmac:String,binddate:String,bindname:String) {
        self.bindname = bindname
        self.binddate = binddate
        self.bindper = bindper
        self.bindmac = bindmac
        self.phone = phone
    }
    
    override init() {
        self.bindname = nil
        self.binddate = nil
        self.bindper = nil
        self.bindmac = nil
        self.phone = nil
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(phone, forKey:"phone")
        aCoder.encode(bindper, forKey:"bindper")
        aCoder.encode(bindmac, forKey:"bindmac")
        aCoder.encode(binddate, forKey:"binddate")
        aCoder.encode(bindname, forKey:"bindname")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String
        self.bindper = aDecoder.decodeObject(forKey: "bindper") as? String
        self.bindmac = aDecoder.decodeObject(forKey: "bindmac") as? String
        self.binddate = aDecoder.decodeObject(forKey: "binddate") as? String
        self.bindname = aDecoder.decodeObject(forKey: "bindname") as? String
    }
}
