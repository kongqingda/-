//
//  BleDataAnalysis.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/12.
//  Copyright © 2017年 qingda kong. All rights reserved.
//  主要用于对数据的接受打包和分发

import UIKit
var instance  = BleDataAnalysis()
class BleDataAnalysis: NSObject,ManagerBledataDelegate{
    let bleorders : BleOrders = BleOrders()
    var batterymsg : UInt8 = 0x80
     let toastview : ToastView = ToastView.instance
    
    class var shareInstance : BleDataAnalysis{
        BleTools.sharedInstance.managerdelegate = instance
        return instance
    }
    
    //接受到蓝牙的通知
    var isbegin : Bool = false
    var alldata : [UInt8] = []
    var length : Int = 0
    func revbledata(data: [UInt8]) {
        
        if data.count<4{
            return
        }
        if isbegin{
            for a in data{
                alldata.append(a)
            }
            if alldata.count == length{
                //不需要校验
                switch alldata[3]{
                case  0x36:
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gettodaystep"), object: alldata)
                default:
                    break
                }
                //需要校验
                if bleorders.ischeck(alldata){
                    print("校验码正确！")
                    switch alldata[3]{
                    case  0x35:
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getallmsg"), object: alldata)
                    case 0x08:
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getECGupdatedata"), object: alldata)
                    default:
                        break
                    }
                    
                }else{
                    print("校验码错误！")
                }
                isbegin = false
            }else if alldata.count > length{
                isbegin = false
                toastview.clear()
            }
        }
        
        if  data[0] == 0x55 && data[1] == 0xAA {
            length = Int(data[2])+3
            alldata.removeAll()
            isbegin = isContinue(length, data)
            alldata = data
            switch data[3]{
            case 0x24:
                switch data[4] {
                case 0:
                    print("时间设置失败")
                    toastview.showToast(content: "时间设置失败")
                case 1:
                    print("时间设置成功")
                default:
                    break
                }
                
            case 0x20:
                batterymsg = data[8]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "batterymsg"), object: batterymsg)
            case 0x35:
                print("解析手表综合信息")
            case 0x36:
                length = 996
                print("解析当日步数统计")
            case 0x08:
                print("解析手表上传的ECG数据")
            case 0x37:
                 print("归12点完成回复")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "back12msg"), object: batterymsg)
            case 0x30:
                 print("调节指针")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "adjusttimemsg"), object: data)
            default:
                isbegin = false
                length = 0
                break
            }
            
        }
        
    }
    func isContinue(_ length:Int,_ data:[UInt8]) -> Bool{
        if length == data.count{
            return false
        }else if data.count < length{
            return true
        }
        return false
    }
}
