//
//  netUtil.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/29.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import Alamofire

private let netUtilShareInstance = netUtil()
let basedebugURL : String = "http://171.221.207.147:8982/healthService/"
let baseURL : String = "http://171.221.207.147:8000/healthService/"
public class netUtil : NSObject{
    class var sharedInstance : netUtil {
        return netUtilShareInstance
    }
    
    //注册
    func resiger(code:String,pwd:String,phone:String) {
        let parameters = ["code":code,"pwd":pwd,"phone":phone]
        let urlString:String = createURL(funcURL: "openUser/register")
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
            .responseJSON { (response) in
               var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("resiger"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
                
                
        }
    }
    
    //手机验证码获取
    func requestVerifyCode(phone:String ,type:String) {
        let parameters = ["phone":phone,"type":type]
        let urlString:String = createURL(funcURL: "openUser/requestVerifyCode")
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
            .responseJSON { (response) in
                var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("requestVerifyCode"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
                
                
        }
    }
    
    //判断手机号是否注册
    func isExisted(phone:String) {
        let parameters = ["phone":phone]
        let urlString:String = createURL(funcURL: "openUser/isExisted")
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
            .validate(contentType: ["application/x-www-form-urlencoded"])
            .responseJSON { (response) in
                var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("isExisted"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
                
                
        }
    }
    
    //登录
    func login(pwd:String,phone:String ) {
        let parameters = ["pwd":pwd,"phone":phone]
        let urlString:String = createURL(funcURL: "openUser/login")
        var json : NSDictionary!
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
            .responseJSON { (response) in
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("login"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
                
                
        }
    }
    
    //修改密码
    func modifyPwd(code:String,pwd:String,phone:String ) {
        let parameters = ["code":code,"pwd":pwd,"phone":phone]
        let urlString:String = createURL(funcURL: "openUser/modifyPwd")
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters)
            .responseJSON { (response) in
                var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("modifyPwd"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
                
                
        }
    }

    //获取个人信息
    func queryPersonalInfo(phone:String) {
        let param = ["phone":phone]
        let header : HTTPHeaders = createheader()
        let urlString:String = createURL(funcURL: "user/queryPersonalInfo")
        Alamofire.request(urlString, method: .post, parameters: param, encoding: URLEncoding.default, headers: header)
            .responseJSON { (response) in
               var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("queryPersonalInfo"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
            }
        
    }
    //保存个人信息
    func savePersonalInfo(name:String?,gender:Int?,height:Int?,weight:Int?,medicalHistory:String?,phone:String?,birthday:String?) {
        let param = ["name": name,"gender": gender?.description,"phone": phone,"height": height?.description,"weight": weight?.description,"birthday": birthday,"medicalHistory": medicalHistory]
        
        let header : HTTPHeaders = createheader()
        let urlString:String = createURL(funcURL: "user/savePersonalInfo")
        Alamofire.request(urlString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
               var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("savePersonalInfo"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
        }
        
    }
    //1.1    获取固件
    func getFirmware(type : String, mcufirwareVersion: String){
        
        var infodata  = [Any]()
        let  data1 = ["moduleName": "mcu",
                    "firwareVersion": mcufirwareVersion]
        let data2 = ["moduleName": "bluetooth",
                     "firwareVersion": mcufirwareVersion]
        infodata.append(data1)
//        let jsondata  = try? JSONSerialization.data(withJSONObject: infodata, options: JSONSerialization.WritingOptions.prettyPrinted)
//        let jsonstring = String.init(data: jsondata!, encoding: String.Encoding.utf8)
        let param = ["type": type,
                     "info": infodata
            ] as [String : Any]
        let header : HTTPHeaders = createheader()
        let urlString:String = createURL(funcURL: "firmware/getFirmware")
        Alamofire.request(urlString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
            .responseJSON { (response) in
                var json : NSDictionary!
                print(json)
                if response.result.isSuccess{
                    json = response.result.value as! NSDictionary
                    print(json)
                    NotificationCenter.default.post(name: Notification.Name("getFirmware"), object: json)
                }
                if response.result.isFailure{
                    print("网络返回错误")
                    NotificationCenter.default.post(name: Notification.Name("neterror"), object: nil)
                    ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
                }
        }
    }
    
    //固件下载
    func devicedownload(fileurl : String){
        
        let urlString = URLRequest(url: URL(string:fileurl)!)
        //设置下载路径。保存到用户文档目录，文件名不变，如果有同名文件则会覆盖
        let destination: DownloadRequest.DownloadFileDestination  = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("downurl.tmp")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(urlString, to: destination).responseData { (downresponse) in
            switch downresponse.result {
            case .success(let data):
                print("文件下载完毕: \(downresponse)")
                NotificationCenter.default.post(name: Notification.Name("devicedownload"), object: data)
                print(data)
            case .failure:
                print("下载返回错误\(downresponse.error)")
                print(downresponse.resumeData)
                ToastView.instance.showToast(content: "下载中断，请检查网络！")
            }
        }
        
//        Alamofire.download(urlString).responseData { (downresponse) in
//            if downresponse.result.isSuccess {
//                let resultdata = downresponse.result.value as! Data
//                NotificationCenter.default.post(name: Notification.Name("devicedownload"), object: resultdata)
//                print(resultdata)
//            }
//            if downresponse.result.isFailure{
//                print("网络返回错误")
//                ToastView.instance.showToast(content: "网络返回错误，请检查网络！")
//            }
//        }
    }
    
    //上传ECG文件 bodyStatus 1：安静状态 2：心脏不适  deviceType 1：手环，2：胸贴 模式  1：mix
    func uploadECGfile(startdate:Date,enddate:Date,mode:Int,bodyStatus:Int,deviceSN:String,phone:String,deviceType:Int,filedata:Data,logFiledata:Data?,signalQualityFile:Data?,frequency:Int)
         {
         let header : HTTPHeaders = createheader()
         let urlString:String = createURL(funcURL: "file/uploadEcgFile")
        var issuccess : Bool = false
            var dataId : Int32 = 0
    
        let param = ["startTime": Int(1000*startdate.timeIntervalSince1970).description,
                     "endTime": Int(1000*enddate.timeIntervalSince1970).description,
                     "mode": mode.description,
                     "bodyStatus": bodyStatus.description,
                     "deviceSN": deviceSN.description,
                     "phone": phone,
                     "deviceType": deviceType.description,
                     "frequency": frequency.description]
      
        Alamofire.upload(multipartFormData: { multipartform in
            
            multipartform.append(filedata, withName: "file", fileName: "data.dat", mimeType: "text/*")
            if logFiledata != nil{
                 multipartform.append(logFiledata!, withName: "logFile", fileName: "data.log", mimeType: "text/*")
            }
            if signalQualityFile != nil{
                 multipartform.append(signalQualityFile!, withName: "signalQualityFile", fileName: "signalQualityFile.txt", mimeType: "text/*")
            }
            for (key, value) in param {
                multipartform.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        },usingThreshold: UInt64(1024),to: urlString,method: .post,headers: header) { results in
            
            switch results{
            case .failure(let error):
                print(error.localizedDescription)
                print("上传失败")
                dataId = 0
                issuccess = false
                self.saveECGdata(startdate, enddate, issuccess, dataId, filedata)
            case .success(request:let req, streamingFromDisk: _, streamFileURL: _):
                  print("上传成功")
                  req.uploadProgress(closure: { progress in
                    print("上传进度：\(progress.fractionCompleted)")
                  })
                  req.responseJSON(completionHandler: { response in
                    var json : NSDictionary!
                    if response.result.isSuccess{
                        
                        issuccess = true
                        json = response.result.value as! NSDictionary
                        print(json["remark"] as! String)
                        
                        dataId = json["dataId"] as! Int32
                        print(json["dataId"] as! Int32)
                        self.saveECGdata(startdate, enddate, issuccess, dataId, filedata)
                       
                    }
                  })
            default:
                break
            }
        }
        
    }
    //保存ECG文件
    func saveECGdata(_ startdate:Date,_ enddate:Date,_ issuccess:Bool,_ dataId:Int32,_ filedata:Data){
        let filedao : FiledocmDao = FiledocmDao.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let datestr = dateFormatter.string(from: startdate)
        let filename = filedao.createfilename(datastyle: 0, phone: FirstViewController.phone, devicename: (BleTools.bindperipheral?.name)!, datestr: datestr)
        let data : ECGdata = ECGdata.init(date: date, enddate: NSDate(), fileurl: filename, isupdate: issuccess, startdate: startdate as NSDate, phone: FirstViewController.phone,devicename:BleTools.bindperipheral?.name,deviceid: BleTools.BLEMAC, dataId: dataId, isread: false, username: LoadViewController.USERNAME,samplerate: Int16(FirstViewController.SAMPLERATE))
        if filedao.savefile(ecgdata: filedata, filename: filename){
            ECGDataDao.sharedInstance.create(data)
            print("数据保存成功")
            
        }
        NotificationCenter.default.post(name: Notification.Name("uploadECGresult"), object: filedata.count)
    }
    
    
    func sizeof(_ d : Int) -> Int{
        let s = d.description
        return s.characters.count
    }

    

    //设置header
    func createheader() -> HTTPHeaders {
        let userdefaults : UserDefaults = .standard
        let token = userdefaults.string(forKey: "token")
        let phone = userdefaults.string(forKey: "phone")
        var header : HTTPHeaders!
        if token != nil{
            header = ["token":token!,"phone":phone!]
        }
        return header
    }
    
    //URL拼接
    func createURL(funcURL:String) -> String {
        var URL : String = baseURL
        URL = URL + funcURL
        return URL
    }
    
}



