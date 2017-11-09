//
//  DiagnosisMsgManager+CoreDataProperties.swift
//  
//
//  Created by 孔庆达 on 2017/10/24.
//
//

import Foundation
import CoreData


extension DiagnosisMsgManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiagnosisMsgManager> {
        return NSFetchRequest<DiagnosisMsgManager>(entityName: "DiagnosisMsg")
    }

    @NSManaged public var dataId: Int32
    @NSManaged public var properties: String?
    @NSManaged public var sentTime: Int64
    @NSManaged public var receiver: String?
    @NSManaged public var ctrlType: Int16
    @NSManaged public var sender: String?
    @NSManaged public var content: String?
    @NSManaged public var isread: Bool

}
