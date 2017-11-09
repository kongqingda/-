//
//  UsermsgManager+CoreDataProperties.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/8.
//  Copyright © 2017年 qingda kong. All rights reserved.
//
//

import Foundation
import CoreData


extension UsermsgManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsermsgManager> {
        return NSFetchRequest<UsermsgManager>(entityName: "Usermsg")
    }

    @NSManaged public var phone: String?
    @NSManaged public var bindper: String?
    @NSManaged public var bindmac: String?
    @NSManaged public var binddate: String?
    @NSManaged public var bindname: String?

}
