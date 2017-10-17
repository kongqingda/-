//
//  ECGmsgDao.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData

class ECGmsgDao: CoreDataDAO {
    
    public static let sharedInstance: ECGmsgDao = {
        let instance = ECGmsgDao()
        return instance
    }()
    //插入方法
    func create(_ model:ECGmsg) -> Bool {
        let context = persistentContainer.viewContext
        
        let ecgmsg = NSEntityDescription.insertNewObject(forEntityName: "ECGmsg", into:context) as! ECGmsgManager
        
        ecgmsg.date = model.date
        ecgmsg.datanum = model.datanum
        ecgmsg.phone  =  model.phone
        ecgmsg.deviceid = model.deviceid
        ecgmsg.mac = model.mac
        //保存数据
        self.saveContext()
        NotificationCenter.default.post(name: Notification.Name("ECGmsg"), object: nil)
        return true
    }
    //修改数据
    //修改Note方法
    public func modify(_ model: ECGmsg) -> Bool {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ECGmsg", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date = %@ and phone = %@", model.date!,model.phone)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count > 0 {
                let ecgmsg = listData[0] as! ECGmsgManager
                ecgmsg.setValue(model.datanum , forKey: "datanum")
                ecgmsg.datanum = model.datanum
                
                //保存数据
                self.saveContext()
                NotificationCenter.default.post(name: Notification.Name("ECGmsg"), object: nil)
            }
        } catch {
            NSLog("修改数据失败")
            return false
        }
        return true
    }
    
    
    //查询所有数据方法
    public func findAll() -> NSMutableArray? {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ECGmsg", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key:"date", ascending:true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let resListData = NSMutableArray()
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            if listData.count > 0 {
                
                for item in listData {
                    let mo = item as! ECGmsgManager
                    let ecgmsg = ECGmsg.init(date: mo.date!, datanum: mo.datanum, deviceid: mo.deviceid!, mac: mo.mac!, phone: mo.phone!)
                    resListData.add(ecgmsg)
                }
                return resListData
            }
        } catch {
            NSLog("查询数据失败")
        }
        
        return nil
    }
    
    //按照主键查询数据方法
    public func findByDate(_ date: String,_ phone:String) -> ECGmsg? {
        
 
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ECGmsg", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date = %@ and phone = %@", date,phone)
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            if listData.count > 0 {
                let mo = listData[0] as! ECGmsgManager
                let ecgmsg = ECGmsg.init(date: mo.date!, datanum: mo.datanum, deviceid: mo.deviceid!, mac: mo.mac!, phone: mo.phone!)
                return ecgmsg
            }
        } catch {
            NSLog("查询数据失败")
        }
        return nil
    }
    
    
}
