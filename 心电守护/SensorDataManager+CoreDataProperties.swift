//
//  SensorDataManager+CoreDataProperties.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/12.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData


extension SensorDataManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorDataManager> {
        return NSFetchRequest<SensorDataManager>(entityName: "SensorData")
    }

    @NSManaged public var phone: String?
    @NSManaged public var date: String?
    @NSManaged public var deviceid: String?
    @NSManaged public var fileurl: String?
    @NSManaged public var isupdate: Bool
    @NSManaged public var stepnum: Int64

}
