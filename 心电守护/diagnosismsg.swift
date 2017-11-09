//
//  diagnosismsg.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/10/24.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class diagnosismsg: NSObject , NSCoding {
     public var dataId: Int32
     public var properties: String?
     public var sentTime: Int64
     public var receiver: String?
     public var ctrlType: Int16
     public var sender: String?
     public var content: String?
     public var isread: Bool
    
    init(dataId:Int32,properties:String,sentTime:Int64,receiver:String,ctrlType:Int16,sender:String,content:String,isread:Bool) {
        self.dataId = dataId
        self.properties = properties
        self.sentTime = sentTime
        self.receiver = receiver
        self.ctrlType = ctrlType
        self.sender = sender
        self.content = content
        self.isread = isread
    }
    
    override init() {
        self.dataId = 0
        self.properties = "properties"
        self.sentTime = 0
        self.receiver = "receiver"
        self.ctrlType = 0
        self.sender = "sender"
        self.content = "content"
        self.isread = false
    }
    // MARK: --实现NSCoding协议
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(dataId, forKey:"dataId")
         aCoder.encode(properties, forKey:"properties")
         aCoder.encode(sentTime, forKey:"sentTime")
         aCoder.encode(receiver, forKey:"receiver")
         aCoder.encode(ctrlType, forKey:"ctrlType")
         aCoder.encode(sender, forKey:"sender")
        aCoder.encode(content, forKey:"content")
        aCoder.encode(isread, forKey:"isread")
    }
    public required init(coder aDecoder: NSCoder) {
        self.dataId = (aDecoder.decodeObject(forKey: "dataId") as? Int32)!
         self.properties = (aDecoder.decodeObject(forKey: "properties") as? String)!
         self.sentTime = (aDecoder.decodeObject(forKey: "sentTime") as? Int64)!
         self.receiver = (aDecoder.decodeObject(forKey: "receiver") as? String)!
         self.ctrlType = (aDecoder.decodeObject(forKey: "ctrlType") as? Int16)!
         self.sender = (aDecoder.decodeObject(forKey: "sender") as? String)!
         self.content = (aDecoder.decodeObject(forKey: "content") as? String)!
        self.isread = (aDecoder.decodeObject(forKey: "isread") as? Bool)!
    }
    
    
}

