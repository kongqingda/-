//
//  DeviceData.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/21.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import CoreBluetooth
public class DeviceData : NSObject{
    var peripheral : CBPeripheral
    var rssi : NSNumber
    init(peripheral:CBPeripheral,rssi:NSNumber) {
        self.rssi = rssi
        self.peripheral = peripheral
    }
    
}
