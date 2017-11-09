//
//  UsermsgDao.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/8.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData

public class UsermsgDao: CoreDataDAO{
    public static let sharedInstance: UsermsgDao = {
        let instance = UsermsgDao()
        return instance
    }()
    
    //插入方法
    func create(_ model:Usermsgmodel) -> Bool {
     
        let context = persistentContainer.viewContext
        
        let usermsg = NSEntityDescription.insertNewObject(forEntityName: "Usermsg", into:context) as! UsermsgManager
        
        usermsg.bindmac = model.bindmac
        usermsg.bindper = model.bindper
        usermsg.binddate = model.binddate
        usermsg.bindname = model.bindname
        usermsg.phone = model.phone
        //保存数据
        if findByDate(model.phone!) != nil{
            modify(model)
        }else{
            self.saveContext()
        }
      
        return true
    }
    
    //按照主键查询数据方法
    public func findByDate(_ phone: String) -> NSMutableArray? {
        
        let resListData = NSMutableArray()
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Usermsg", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "phone = %@",phone)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count == 0{
                return nil
            }
            for item in listData{
                let mo = item as! UsermsgManager
                let usermsg = Usermsgmodel.init(phone: phone, bindper: mo.bindper!, bindmac: mo.bindmac!, binddate: mo.binddate!, bindname: mo.bindname!)
                resListData.add(usermsg)
            }
            return resListData
        } catch {
            NSLog("查询数据失败")
        }
        return nil
    }
    //修改数据
    func modify(_ model: Usermsgmodel) -> Bool {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Usermsg", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "phone = %@",model.phone!)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count > 0 {
                let usermsg = listData[0] as! UsermsgManager
                usermsg.setValue(model.bindname , forKey: "bindname")
                usermsg.setValue(model.binddate , forKey: "binddate")
                usermsg.setValue(model.bindmac , forKey: "bindmac")
                usermsg.setValue(model.bindper , forKey: "bindper")
                usermsg.bindname = model.bindname
                usermsg.binddate = model.binddate
                usermsg.bindmac = model.bindmac
                usermsg.bindper = model.bindper
                //保存数据
                self.saveContext()
                
            }
        } catch {
            print("修改数据失败")
            return false
        }
        return true
    }
    
    //删除数据的方法
    public func remove(_ phone : String ) -> Bool {
        
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Usermsg", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "phone = %@",phone)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count > 0 {
                let deletedata  = listData[0] as! NSManagedObject
                context.delete(deletedata)
                print("删除数据成功")
                self.saveContext()
            }
        } catch {
            print("删除数据失败")
            return false
        }
        return true
    }

}
