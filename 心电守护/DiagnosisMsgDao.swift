//
//  DiagnosisMagDao.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/10/24.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData


class DiagnosisMsgDao: CoreDataDAO {
    
    public static let sharedInstance: DiagnosisMsgDao = {
        let instance = DiagnosisMsgDao()
        return instance
    }()
    
    //插入方法
    func create(_ model:diagnosismsg) -> Bool {
        let context = persistentContainer.viewContext
        
        let diagmsg = NSEntityDescription.insertNewObject(forEntityName: "DiagnosisMsg", into:context) as! DiagnosisMsgManager
        
        diagmsg.content = model.content
        diagmsg.ctrlType = model.ctrlType
        diagmsg.dataId  =  model.dataId
        diagmsg.properties = model.properties
        diagmsg.receiver = model.receiver
        diagmsg.sender = model.sender
        diagmsg.sentTime = model.sentTime
        diagmsg.isread = model.isread
        
        //保存数据
        self.saveContext()
        NotificationCenter.default.post(name: Notification.Name("DiagnosisMsg"), object: nil)
        return true
    }
    //修改数据
    //修改Note方法
    public func modify(_ model: diagnosismsg) -> Bool {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DiagnosisMsg", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "dataId = %i and receiver = %@", model.dataId,model.receiver!)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count > 0 {
                let diagmsg = listData[0] as! DiagnosisMsgManager
                diagmsg.setValue(model.isread , forKey: "isread")
                diagmsg.isread = model.isread
                //保存数据
                self.saveContext()
                NotificationCenter.default.post(name: Notification.Name("DiagnosisMsg"), object: nil)
            }
        } catch {
            NSLog("修改数据失败")
            return false
        }
        return true
    }
    
    
    //按照主键查询数据方法
    public func findBydataId(_ dataId : Int32,_ username : String) -> diagnosismsg? {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DiagnosisMsg", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "dataId = %i and receiver = %@", dataId,username)
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            if listData.count > 0 {
                let mo = listData[0] as! DiagnosisMsgManager
                let diamsg = diagnosismsg.init(dataId: mo.dataId, properties: mo.properties!, sentTime: mo.sentTime, receiver: mo.receiver!, ctrlType: mo.ctrlType, sender: mo.sender!, content: mo.content!,isread: mo.isread)
                return diamsg
            }
        } catch {
            NSLog("查询数据失败")
        }
        return nil
    }
    
    
}
