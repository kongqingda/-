//
//  BleTools.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/21.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import CoreBluetooth
import Foundation


let UUID_HOLLO_SERVICE = "FFF0"; //服务的UUID
let UUID_HOLLO_DATA_RECEIVE = "FFF1" //接受数据特征的UUID
let UUID_HOLLO_DATA_SEND = "FFF2" //发送数据特征的UUID
let UUID_CLIENT_CHARACTERISTIC_CONFIG = "2902"

let UUID_Device_SERVICE = "180A"
let UUID_SOFTREV_CHAR = "2A28"
let UUID_SN  = "2A25"
var UUID_SERVICE : CBUUID!
var UUID_CHARACTERISTIC_READ : CBUUID!
var UUID_CHARACTERISTIC_WRITE : CBUUID!
var UUID_CHARACTERISTIC_NOTIFY : CBUUID!

enum blestate : Int {
    case ble_on = 0
    case ble_off = 1
    case ble_conn = 2
    case ble_disconn = 3
    case ble_connfail = 4
}
//自定义协议实现对接收到的蓝牙数据的管理
protocol ManagerBledataDelegate {
    func revbledata(data:[UInt8])
}
//发送实时心电数据的协议
protocol ManagerECGdataDelegate {
    func revECGdata(data:[UInt8])
}


let bletools : BleTools = BleTools()
class BleTools: NSObject,CBPeripheralDelegate, CBCentralManagerDelegate{
    
    class var sharedInstance : BleTools{
        bletools.initBlueTooth()
        return bletools
    }
    var managerdelegate : ManagerBledataDelegate?
    var managerecgdelegate : ManagerECGdataDelegate?
    static var centralManager : CBCentralManager?
    static var BTState = blestate.ble_off
    var nowperipheral ,myperipheral : CBPeripheral?
    static var bindperipheral : CBPeripheral?
    static var characteristicTx : CBCharacteristic?
    static var characteristicRx : CBCharacteristic?
    var chasoft : CBCharacteristic?
    var chasn : CBCharacteristic?
    
    var deviceTx : CBCharacteristic?
    var deviceRx : CBCharacteristic?
    var deviceSx : CBCharacteristic?
    static var SOFTVERSION : String = "v1.0.0"
    static var DEVICESN : String = "1.0.0"
    
    let toastview : ToastView = ToastView.instance
    static var peripheralArray: Array = [CBPeripheral]();
    static var deviceArray : Array = [DeviceData]()
    
    //    let uuidService = CBUUID.init(string: SERVICE_UUID);
    //    let uuidCharTx = CBUUID.init(string: CHAR_TX_UUID);
    //    let uuidCharRx = CBUUID.init(string: CHAR_RX_UUID);
    
    let uuidHelloService = CBUUID.init(string: UUID_HOLLO_SERVICE)
    let uuidHelloDataReceive = CBUUID.init(string: UUID_HOLLO_DATA_RECEIVE)
    let uuidHelloDataSend = CBUUID.init(string: UUID_HOLLO_DATA_SEND)
    let uuidClientCharacterisiticConfig = CBUUID.init(string: UUID_CLIENT_CHARACTERISTIC_CONFIG)
    
    let uuidDeviceService = CBUUID.init(string: UUID_Device_SERVICE)
    let uuidSoftRevChar = CBUUID.init(string: UUID_SOFTREV_CHAR)
    let uuidSN = CBUUID.init(string: UUID_SN)
    
    // 初始化蓝牙
    func initBlueTooth() {
        if BleTools.centralManager == nil{
            BleTools.centralManager = CBCentralManager.init(delegate: self, queue: nil);
            BleTools.centralManager?.delegate = self
        }
    }
    
    // 扫描外设
    func scanDevice() {

        BleTools.peripheralArray.removeAll()
        BleTools.deviceArray.removeAll()
        BleTools.centralManager!.scanForPeripherals(withServices: nil, options: nil);
    }
    
    // 停止扫描外设
    func stopScanDevice() {
        BleTools.centralManager!.stopScan();
    }
    
    //  连接设备
    func connectDevice(per:CBPeripheral) {
        BleTools.centralManager!.connect(per, options: nil);
        myperipheral = per;
    }
    
    //发送数据
    func APPsendData(data:Data) -> Void {
       print(data)
        if BleTools.BTState == blestate.ble_conn{
            myperipheral?.writeValue(data, for: BleTools.characteristicTx!, type: CBCharacteristicWriteType.withResponse)
            print([UInt8](data))

        }else{
            toastview.showToast(content: "请检查蓝牙连接！")
        }
        
    }
    
    //  断开连接
    func disConnectDevice(per:CBPeripheral) {
        BleTools.centralManager!.cancelPeripheralConnection(per);
        BleTools.bindperipheral = nil
    }
    
    //MARK:
    //MARK:      centralManager代理方法
    //    回调方法
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            print("蓝牙状态已经打开！")
        case .poweredOff:
            print("蓝牙状态关闭！")
            BleTools.BTState = blestate.ble_off
             NotificationCenter.default.post(name: Notification.Name("bleconn"), object: nil, userInfo: nil)
        case .unsupported:
            print("不支持蓝牙！")
        default:
            break;
        }
    }
    //    已经扫描到外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("已经扫描到了外设！")

        if (peripheral.name != nil && (peripheral.name?.components(separatedBy: "TH").count)!>1){
            nowperipheral = peripheral
            peripheral.delegate = self
            peripheral.readRSSI()
            filterDevice(per: nowperipheral!,rssi: RSSI)
            //NotificationCenter.default.post(name: Notification.Name("reloadlist"), object: BleTools.peripheralArray)
        }
    }
    
    //  过滤扫描到的外设
    func filterDevice(per: CBPeripheral,rssi: NSNumber) {
            var ishas : Bool = true
            for i in 0..<BleTools.peripheralArray.count {
                if BleTools.peripheralArray.contains(per){
                    BleTools.peripheralArray[i] = per
                    BleTools.deviceArray[i] = DeviceData.init(peripheral: per, rssi: rssi)
                    ishas = false
                    break
                }
            }
            if ishas && rssi.intValue<0{
                BleTools.peripheralArray.append(per)
                BleTools.deviceArray.append(DeviceData.init(peripheral: per, rssi: rssi))
            }
    }
    //更新RSSI的回调
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        for i  in 0 ..< BleTools.peripheralArray.count{
            
            if BleTools.peripheralArray[i] == peripheral{
                peripheral.readRSSI()
                BleTools.peripheralArray[i] = peripheral
                print("蓝牙RSSI值\(RSSI)")
                NotificationCenter.default.post(name: Notification.Name("reloadlist"), object: nil, userInfo: nil)
            }
            
                
        }
    }
    // 连接外设成功回调        如果连接成功扫描服务
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已经连接上了外设！")
        stopScanDevice()
        BleTools.bindperipheral = peripheral
        peripheral.discoverServices([uuidHelloService,uuidDeviceService])
        print(String.init(format: "连接了%@",peripheral.name!))
        
    }
    // 外设已经断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("已经与外设断开了连接")
        BleTools.BTState = blestate.ble_disconn
        BleTools.bindperipheral = nil
        BleTools.characteristicTx = nil
        BleTools.characteristicRx = nil
        chasoft = nil
        chasn = nil
        NotificationCenter.default.post(name: Notification.Name("bleconn"), object: nil, userInfo: nil)
        
    }
    // 外设连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("与外设连接失败！失败原因：\(error!)")
        BleTools.BTState = blestate.ble_connfail
        NotificationCenter.default.post(name: Notification.Name("bleconn"), object: nil, userInfo: nil)
    }
    
    // 已经发现了服务    发现服务之后去扫描特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("发现服务失败！失败原因：\(error!)")
        }else{
            
            for service:CBService in peripheral.services! {
                
                print("发现了服务！UUID=\(service.uuid)")
                
                if (service.uuid.uuidString == UUID_HOLLO_SERVICE) {
                    peripheral.discoverCharacteristics([uuidHelloDataSend,uuidHelloDataReceive], for: service)
                    print("1现在开始去搜寻服务UUID=\(service.uuid)中的特征！")
                }
                if (service.uuid.uuidString == UUID_Device_SERVICE) {
                    peripheral.discoverCharacteristics([uuidSoftRevChar,uuidSN], for: service)
                    print("2现在开始去搜寻服务UUID=\(service.uuid)中的特征！")
                }
            }
        }
       
    }
    
    //    已经发现了特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("发现特征失败！失败原因:\(error!)")
        }else{
            print("正在发现特征")
            if service.uuid.uuidString == UUID_HOLLO_SERVICE{
                didFindCharacteristic(service: service)
            }
            if service.uuid.uuidString == UUID_Device_SERVICE{
                didFindDeviceDonfig(service: service)
            }
        }
    }
    //    属性的读写特征分配
    func didFindCharacteristic(service : CBService) -> Void {
        
          BleTools.characteristicTx = nil;
          BleTools.characteristicRx = nil;
       
        
        print("正在特征分配")
        let chaArry:[CBCharacteristic] = service.characteristics!
        for cha:CBCharacteristic in chaArry {
            if cha.uuid.isEqual(uuidHelloDataReceive) {
                BleTools.characteristicRx = cha
                myperipheral?.readValue(for: cha)
                myperipheral?.setNotifyValue(true, for: cha) //发现订阅特征之后，进行注册
                    
            }
            if cha.uuid.isEqual(uuidHelloDataSend){
                BleTools.characteristicTx = cha
                BleTools.BTState = blestate.ble_conn
            }
            
        }
        
    }
    //设备属性的读取
    func didFindDeviceDonfig(service : CBService){
        chasn = nil
        chasoft = nil
        print("2正在特征分配")
        let chaArry:[CBCharacteristic] = service.characteristics!
        for cha:CBCharacteristic in chaArry {
       
            if cha.uuid.isEqual(uuidSoftRevChar){
                myperipheral?.readValue(for: cha)
                chasoft = cha
            }
            if cha.uuid.isEqual(uuidSN){
                myperipheral?.readValue(for: cha)
                chasn = cha
            }
        }
        
    }
    //搜索Descriptors
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == uuidSoftRevChar{
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    //获取Descriptors的值
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
     
    }
    
    //   订阅是否成功的回调
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("注册订阅通知失败!失败原因：\(characteristic.uuid.uuidString)\(error)")
            if characteristic == BleTools.characteristicRx{
                 disConnectDevice(per: peripheral)
            }
            
        }else{
           
            if characteristic.uuid == uuidHelloDataReceive{
                print("注册订阅成功！")
                BleTools.BTState = blestate.ble_conn
                print(BleTools.BTState)
                NotificationCenter.default.post(name: Notification.Name("bleconn"), object: nil, userInfo: nil)
            }
            
        }
        
    }
    
    
    // 接收从外设发来的数据   不管是通知还是读取都是从以下方法中获取数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        BleTools.bindperipheral = peripheral
        print("接收到从外设发来的数据了！")
        if error != nil {
            print("接收数据时发生错误！错误原因：\(error)")
        }else{
            if characteristic.uuid == uuidSoftRevChar{
                 let allData : Data = characteristic.value!;
                print("2接收到从外设发来的数据了！")
                BleTools.SOFTVERSION = String.init(data: allData, encoding: String.Encoding.utf8)!
                print(BleTools.SOFTVERSION)
            }
            
            if characteristic.uuid == uuidSN{
                let allData : Data = characteristic.value!;
                print("2接收到从外设发来的数据了！")
                BleTools.DEVICESN = String.init(data: allData, encoding: String.Encoding.utf8)!
                print(BleTools.DEVICESN)
            }
            
            if characteristic.uuid == uuidHelloDataReceive {
                let allData : Data = characteristic.value!;
                print("1接收到从外设发来的数据了！")
                BleTools.BTState = blestate.ble_conn
                print(BleTools.BTState)
                print(allData)
                let data : [UInt8] = [UInt8](allData)
                print(data)
                //回复状态
                if data.count  == 1{
                    switch data[0] {
                    case WATCHSTATUS.STATUS_OK.rawValue:
                        NotificationCenter.default.post(name: Notification.Name("STATUS"), object: WATCHSTATUS.STATUS_OK, userInfo: nil)
                    case WATCHSTATUS.STATUS_FAILED.rawValue:
                        NotificationCenter.default.post(name: Notification.Name("STATUS"), object: WATCHSTATUS.STATUS_FAILED, userInfo: nil)
                    case WATCHSTATUS.STATUS_FINISH.rawValue:
                        NotificationCenter.default.post(name: Notification.Name("STATUS"), object: WATCHSTATUS.STATUS_FINISH, userInfo: nil)
                    case WATCHSTATUS.STATUS_UNKNOW.rawValue:
                        NotificationCenter.default.post(name: Notification.Name("STATUS"), object: WATCHSTATUS.STATUS_UNKNOW, userInfo: nil)
                    default:
                        managerdelegate?.revbledata(data: data)
                        managerecgdelegate?.revECGdata(data: data)
                        NotificationCenter.default.post(name: NSNotification.Name("REVDATA"), object: data, userInfo: nil)
                        break
                    }
                }else{
                    managerdelegate?.revbledata(data: data)
                    managerecgdelegate?.revECGdata(data: data)
                    NotificationCenter.default.post(name: NSNotification.Name("REVDATA"), object: data, userInfo: nil)
                }
            }
        }
    }
    
    
    
    //  向外设写入数据成功的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("发送数据成功")
        if error != nil {
            print("为名字为：\(peripheral.name)的设备，UUID为\(characteristic.uuid)的特征写入数据时失败！失败原因：\(error)")
        }else{
            BleTools.bindperipheral = peripheral
             BleTools.BTState = blestate.ble_conn
            print("为名字为：\(peripheral.name)的设备，UUID为\(characteristic.uuid)的特征写入数据成功！")
            
        }
    }
    
    
    
    
    
}
