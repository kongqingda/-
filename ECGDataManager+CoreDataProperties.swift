//
//  ECGDataManager+CoreDataProperties.swift
//  
//
//  Created by 孔庆达 on 2017/10/24.
//
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
    @NSManaged public var dataId: Int32
    @NSManaged public var username: String?
    @NSManaged public var isread: Bool
    @NSManaged public var samplerate : Int16

}
