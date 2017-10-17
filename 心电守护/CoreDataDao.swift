//
//  CoreDataDao.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import CoreData
open class CoreDataDAO: NSObject {
    
    //返回持久化存储容器
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("持久化存储容器错误：", error.localizedDescription)
            }
        })
        return container
    }()
    
    /// MARK: - 保存数据
    //保存数据
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("数据保存错误：", nserror.localizedDescription)
                
            }
        }
    }
}

