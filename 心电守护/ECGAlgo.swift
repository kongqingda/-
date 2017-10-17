//
//  ECGAlgo.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/25.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class ECGAlgo: NSObject ,NskAlgoSdkDelegate,TGStreamDelegate{
    static var algosdk : NskAlgoSdk = NskAlgoSdk.sharedInstance() as! NskAlgoSdk
    static var instance : ECGAlgo = ECGAlgo()
    

    
    
    func stateChanged(_ state: NskAlgoState, reason: NskAlgoReason) {
        
    }
    func ecgAlgoValue(_ ecg_value_type: NskAlgoECGValueType, ecg_value ecg_valid: NSNumber!, ecg_valid ECG_valid: Bool) {
        
    }
    func ecgHRVFDAlgoValue(_ hf: NSNumber!, lf: NSNumber!, lfhf_ratio: NSNumber!, hflf_ratio: NSNumber!) {
        
    }
    func ecgHRVTDAlgoValue(_ nn50: NSNumber!, sdnn: NSNumber!, pnn50: NSNumber!, rrTranIndex: NSNumber!, rmssd: NSNumber!) {
        
    }
    func signalQuality(_ signalQuality: NskAlgoSignalQuality) {
        
    }
    func overallSignalQuality(_ signalQuality: NSNumber!) {
        
    }
    func onRecordFail(_ flag: RecrodError) {
        
    }
    func onStatesChanged(_ connectionState: ConnectionStates) {
        
    }
    func onChecksumFail(_ payload: UnsafeMutablePointer<UInt8>!, length: UInt, checksum: Int) {
        
    }
    func onDataReceived(_ datatype: Int, data: Int32, obj: NSObject!, deviceType: DEVICE_TYPE) {
        
    }

}
