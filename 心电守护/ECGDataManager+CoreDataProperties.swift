//
//  ECGDataManager+CoreDataProperties.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/6.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData


extension ECGDataManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECGDataManager> {
        return NSFetchRequest<ECGDataManager>(entityName: "ECGData")
    }

    @NSManaged public var date: String?
    @NSManaged public var deviceid: String?
    @NSManaged public var devicename: String?
    @NSManaged public var enddate: NSDate?
    @NSManaged public var fileurl: String?
    @NSManaged public var isupdate: Bool
    @NSManaged public var phone: String?
    @NSManaged public var startdate: NSDate?

}
