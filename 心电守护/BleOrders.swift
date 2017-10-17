//
//  BleOrders.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/21.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
//下行CMD
enum SENDCMD : UInt8{
    case WatchHelloCmd = 0x80
    case SportDataCmd = 0x85
    case FlashCmd = 0x88
    case MCUCmd1 = 0x89
    case MCUCmd2 = 0x8A
    case MCUCmd3 = 0x8B
    case RRCmd = 0x8C
    case PEDatacmd1 = 0x8D
    case PEDatacmd2 = 0x8E
    case PairCmd = 0x90
    case SoftVerCmd = 0x91
    case SteppaceCmd = 0x92
    case OKPairCmd =  0x93
    case WatcheResetCmd = 0x94
    case WatchPulseWidthCmd = 0x95
    case WatchBatteryCmd = 0xA0
    case WatchSoundCmd = 0xA1
    case setSoundCmd = 0xA2
    case watchTimeCmd = 0xA3
    case SetTimeCmd = 0xA4
    case SetECGCmd = 0xA5
    case SetWatchLightCmd = 0xA6
    case SetWatchShockCmd = 0xA7
    case OpenDebugUARTCmd = 0xA8
    case SetFactoryCmd = 0xA9
    case SetDebugCmd = 0xAA
    case ClearPECmd = 0xAB
    case AdjustTimeCmd = 0xB0
    case AdjustTimeCmd_hh = 0xB1
    case AdjustTimeCmd_mm = 0xB2
    case AdjustTimeCmd_ss = 0xB3
    case SetSNCmd = 0xB4
    case GetAllMessageCmd = 0xB5
    case GetSportMessageCmd = 0xB6
    case Test12Cmd = 0xB7
    case GetEVCmd = 0xB8
    case WriteCPCmd = 0xBA
    case GetAddcmd = 0xBB
    case SendStateCmd = 0xFF
}

//上行CMD
enum ReceiveCMD : UInt8{
    case APPhelloCmd = 0x00
    case ECGSensorCmd = 0x07

}
enum WATCHSTATUS : UInt8{
    case STATUS_OK = 0
    case STATUS_FAILED = 1
    case STATUS_UNKNOW = 2
    case STATUS_FINISH = 3


}

public class BleOrders : NSObject{
    let maxlength : Int = 254 //数据包最大长度
    
    let SYNC : Array<UInt8> = [0x55,0xAA] //同步字节
    var SendOrder : Array<UInt8>!//总字节
    var SendData : Array<UInt8>!//数据字节
    var Length : UInt8!//长度字节
    
    
    func myorder(cmd : SENDCMD,data : Array<UInt8>?) -> Array<UInt8> {
        var n : Int = 0
        let sync : Array<UInt8> = self.SYNC
        var length : UInt8 = 0;
        var alldata : Array<UInt8> = sync
        var checksum : UInt8!
        if data == nil{
             length = UInt8(2)
        }else{
             length = UInt8((data?.count)! + 1 + 1)
        }
       
        alldata.append(length)
        alldata.append(cmd.rawValue)
        if data != nil{
            for d : UInt8 in data!{
                alldata.append(d)
            }
        }
        for i : UInt8 in alldata{
            n = n + Int(i)
        }
        n = ~n & 0xff
        checksum = UInt8(n)
        alldata.append(checksum)
        return alldata
    }

    //检查checksum是否正确
    func ischeck(_ baodata : Array<UInt8>) -> Bool {
        let n = baodata.count
        var m : Int = 0
        let checksum = baodata[n-1]
        var data = baodata
        data.remove(at: n-1)
        for d in data{
            m = m + Int(d)
        }
        m = ~m & 0xff
        if  checksum == UInt8(m) {
            print("校验码正确")
            return true
        }else{
            print("校验码错误")
            return false
        }
    }
}
