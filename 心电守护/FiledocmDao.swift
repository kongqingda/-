//
//  FiledocmDao.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/5.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class FiledocmDao: NSObject {
    
    var homedic : String
    var paths : Array<String>
    var dir : String
    var toastview : ToastView
    override init() {
         homedic  = NSHomeDirectory()
         paths  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
         dir  = paths[0]
        toastview = ToastView.instance
    }
    //存数据
    func savefile(ecgdata:Data,filename:String) -> Bool {
        let filepath : String = getfilepath(filename: filename)

        do {
            let url : URL = URL.init(fileURLWithPath: filepath)
            try ecgdata.write(to: url, options: .atomic)
            //try ecgdata.write(to: URL.init(fileURLWithPath: filepath))
            print("文件保存成功")
             return true
        } catch  {
            toastview.showToast(content: "文件保存有问题")
            print("文件保存有问题")
             return false
            
        }
        
        //if ecgdata.write(toFile: filepath, atomically: true)
        
    }
    
    //创建文件名
    func createfilename(datastyle: Int, phone : String,devicename : String,datestr : String?) -> String{
        var filenamehead : String = ""
        switch datastyle {
        case 0:
            filenamehead = "ECG"
        case 1:
            filenamehead = "SENSOR"
        default:
            break
        }
        let dateformatter : DateFormatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        var filename : String = ""
        if datestr == nil{
            dateformatter.string(from: Date())
            filename = String.init(format: "%@-%@-%@-%@.dat",filenamehead, phone,devicename, dateformatter.string(from: Date()))

        }else{
             filename = String.init(format: "%@-%@-%@-%@.dat",filenamehead,phone,devicename, datestr!)
        }
            return filename
    }
    
    //取数据
    func readfile(filename:String) -> Data?{
        //let readdata = NSData.dataWithContentsOfMappedFile(filepath)
        var readdata : Data? = nil
        let filepath = self.getfilepath(filename: filename)
        do {
            let url : URL = URL.init(fileURLWithPath: filepath)
            
            try readdata = Data.init(contentsOf: URL.init(fileURLWithPath: filepath), options: .mappedRead)
            
            return readdata
        } catch  {
            toastview.showToast(content: "文件读取错误")
            print("文件读取错误")
            return readdata
        }

        
    }
    
    func getfilepath(filename:String) -> String{
        let filepath : String = dir.appendingFormat("/%@", filename)
        return filepath
    }
    

}
