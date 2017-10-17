//
//  SensorDataDao.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/12.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData

class SensorDataDao: CoreDataDAO {
    
    
    public static let sharedInstance: SensorDataDao = {
        let instance = SensorDataDao()
        
        return instance
    }()
    //插入方法
    func create(_ model:Sensordatamodel) -> Bool {
        let dateformatter : DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        let context = persistentContainer.viewContext
        
        let sensordata = NSEntityDescription.insertNewObject(forEntityName: "SensorData", into:context) as! SensorDataManager
        
        let findresult = findByDate(model.date!, model.phone!)
            sensordata.date = model.date
            sensordata.fileurl = model.fileurl
            sensordata.phone = model.phone
            sensordata.isupdate = model.isupdate
            sensordata.deviceid = model.deviceid
            sensordata.stepnum = model.stepnum
            //保存数据
            self.saveContext()
        let alldata = findAll(phone: model.phone!)
            if alldata.count>0{
                for i in alldata{
                    let data = i as! Sensordatamodel
                    let date_i = dateformatter.date(from: data.date!)
                    let inday = Int((date_i?.timeIntervalSinceNow)!)/(60*60*24)
                    if inday < -30{
                        remove(data.date!, data.phone!)
                    }

                }
            }
        
        return true
    }
    //删除数据的方法
    public func remove(_ date: String,_ phone : String ) -> Bool {
        
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SensorData", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date = %@ and phone = %@", date,phone)
        
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
    
    //查询所有数据方法
    public func findAll(phone:String) -> NSMutableArray {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SensorData", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key:"date", ascending:true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = NSPredicate(format: "phone = %@",phone)
        let resListData = NSMutableArray()
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            if listData.count > 0 {
                
                for item in listData {
                    let mo = item as! SensorDataManager
                    let sensordata = Sensordatamodel.init(date: mo.date!, fileurl: mo.fileurl!, isupdate: mo.isupdate, phone: mo.phone!,deviceid: mo.deviceid!,stepnum: mo.stepnum)
                    resListData.add(sensordata)
                }
            }
        } catch {
            NSLog("查询数据失败")
        }
        
        return resListData
    }
    
    //按照主键查询数据方法
    public func findByDate(_ date: String,_ phone: String) -> NSMutableArray? {
        
        let resListData = NSMutableArray()
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SensorData", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date = %@ and phone = %@",date,phone)
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            for item in listData{
                let mo = item as! SensorDataManager
                let sensordata = Sensordatamodel.init(date: mo.date!, fileurl: mo.fileurl!, isupdate: mo.isupdate, phone: mo.phone!,deviceid: mo.deviceid!,stepnum: mo.stepnum)
                resListData.add(sensordata)
            }
            return resListData
        } catch {
            NSLog("查询数据失败")
        }
        return nil
    }
    //修改数据
    public func modify(_ model: Sensordatamodel) -> Bool {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SensorData", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "date = %@ and phone = %@", model.date!,model.phone!)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count > 0 {
                let sensordata = listData[0] as! SensorDataManager
                sensordata.setValue(model.fileurl , forKey: "fileurl")
                sensordata.setValue(model.stepnum , forKey: "stepnum")
                sensordata.stepnum = model.stepnum
                sensordata.fileurl = model.fileurl
                
                //保存数据
                self.saveContext()
               
            }
        } catch {
            print("修改数据失败")
            return false
        }
        return true
    }
    
    
}
