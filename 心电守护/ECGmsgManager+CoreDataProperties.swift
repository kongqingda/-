//
//  ECGmsgManager+CoreDataProperties.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/6.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData


extension ECGmsgManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECGmsgManager> {
        return NSFetchRequest<ECGmsgManager>(entityName: "ECGmsg")
    }

    @NSManaged public var datanum: Int16
    @NSManaged public var date: String?
    @NSManaged public var deviceid: String?
    @NSManaged public var mac: String?
    @NSManaged public var phone: String?

}
