//
//  DBManager.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreData

class ECGDataDao: CoreDataDAO {
   
    
    public static let sharedInstance: ECGDataDao = {
        let instance = ECGDataDao()
        
        return instance
    }()
 //插入方法
    func create(_ model:ECGdata) -> Bool {
        let ecgmsgdao : ECGmsgDao = ECGmsgDao.sharedInstance
        
    
        let context = persistentContainer.viewContext
        
        let ecgdata = NSEntityDescription.insertNewObject(forEntityName: "ECGData", into:context) as! ECGDataManager
        
        ecgdata.date = model.date
        ecgdata.enddate = model.enddate
        ecgdata.startdate  =  model.startdate
        ecgdata.fileurl = model.fileurl
        ecgdata.phone = model.phone
        ecgdata.isupdate = model.isupdate
        ecgdata.deviceid = model.deviceid
        ecgdata.devicename = model.devicename
        //保存数据
        self.saveContext()
        let ecgmsg = ecgmsgdao.findByDate(model.date!, model.phone!)
        if ecgmsg != nil{
            ecgmsgdao.modify(ECGmsg.init(date: (ecgmsg?.date!)!, datanum: (ecgmsg?.datanum)!+1, deviceid:(ecgmsg?.deviceid)! , mac: (ecgmsg?.mac)!,phone: (ecgmsg?.phone)!))
        }else{
            ecgmsgdao.create(ECGmsg.init(date: model.date!, datanum: 1, deviceid:(model.deviceid)! , mac: " ",phone: model.phone!))
        }
        return true
    }
    
    //查询所有数据方法
    public func findAll() -> NSMutableArray {
        
        let context = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ECGData", in: context)
        
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
                    let mo = item as! ECGDataManager
                    let ecgdata = ECGdata.init(date: mo.date!, enddate: mo.enddate!, fileurl: mo.fileurl!, isupdate: mo.isupdate, startdate: mo.startdate!, phone: mo.phone!,devicename: mo.devicename!,deviceid: mo.deviceid!)
                    resListData.add(ecgdata)
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
        
        let entity = NSEntityDescription.entity(forEntityName: "ECGData", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key:"startdate", ascending:true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = NSPredicate(format: "date = %@ and phone = %@",date,phone)

        
        do {
            let listData = try context.fetch(fetchRequest)
            
             for item in listData{
                let mo = item as! ECGDataManager
                let ecgdata = ECGdata.init(date: mo.date!, enddate: mo.enddate!, fileurl: mo.fileurl!, isupdate: mo.isupdate, startdate: mo.startdate!, phone: mo.phone!,devicename: mo.devicename!,deviceid: mo.deviceid!)
                resListData.add(ecgdata)
            }
            return resListData
        } catch {
            NSLog("查询数据失败")
        }
        return nil
    }
    

}
