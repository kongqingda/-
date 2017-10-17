//
//  SyncDataViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//  数据同步

import UIKit

class SyncDataViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var progresslabel: UILabel!
    @IBOutlet weak var SyncTableView: UITableView!
    @IBOutlet weak var SyncLabel: UILabel!
    @IBOutlet weak var SyncView: UIView!
    @IBOutlet weak var SyncBtn: UIButton!
    @IBOutlet weak var SyncProgressView: UIProgressView!
    let main : MainController = MainController()
    var phone : String = ""
    let filedao : FiledocmDao = FiledocmDao()
    let bleorder : BleOrders = BleOrders()
    var tabledata : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.SyncTableView.delegate = self
        self.SyncTableView.dataSource = self
        BleDataAnalysis.shareInstance
        NotificationCenter.default.addObserver(self, selector: #selector(revdata(_:)), name: Notification.Name("getECGupdatedata"), object: nil)
        
        let userdefaults : UserDefaults = .standard
        phone = userdefaults.string(forKey: "phone")!
        // Do any additional setup after loading the view.
        SyncTableView.isHidden = true
        SyncView.isHidden = true
        if BleTools.BTState == .ble_conn{
            if FourViewController.updateecgdata == 0{
                self.SyncTableView.isHidden = true
                self.SyncLabel.text = "手表没有要上传的ECG数据"
            }else{
                self.SyncTableView.isHidden = false
                self.SyncLabel.text = "点击同步上传手表ECG数据"
            }
        }else{
                self.SyncLabel.text = "蓝牙未连接，请检查蓝牙连接！"
            ToastView.instance.showToast(content: "蓝牙未连接，请检查蓝牙连接！")
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         MainController.isSendable = true
        print("数据同步关闭")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func SyncBtnAction(_ sender: Any) {
        var senddata : Array<UInt8> = []
        
        senddata = bleorder.myorder(cmd: SENDCMD.FlashCmd, data: nil)
        print(senddata.description)
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
        MainController.isSendable = false
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath as IndexPath)
        cell.imageView?.image = UIImage.init(named: "icon_ecg.png")
        cell.textLabel?.text = "数据测量时间:"
        cell.detailTextLabel?.text = tabledata[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabledata.count
    }
    
    var hashead : Bool = false
    var length : Int = 0
    var revdata : [UInt8] = []
    var data_length : Int = 0
    var data_year : Int32 = 0
    var data_month : Int32 = 0
    var data_day : Int32 = 0
    var data_starthh : Int32 = 0
    var data_startmm : Int32 = 0
    var data_startss : Int32 = 0
    var data_endhh : Int32 = 0
    var data_endmm : Int32 = 0
    var data_endss : Int32 = 0
    var isContinue : Bool = false
    var savedata : Data = Data()
    var savelength : Int = 0
    var isAnalysis : Bool = false
    
    //解析接受到的数据
    func revdata(_ notification : Notification){
        revdata = notification.object as! [UInt8]
        //先判断数据包中是否含有头文件信息-时间信息
        if revdata[8] == 0x59 && revdata[9] == 0x72 && revdata[10] == 0x27 && revdata[11] == 0x95{
            self.SyncView.isHidden = false
            self.SyncProgressView.progress = 0
            progresslabel.text = String.init(format: "%d%", 0)
            savelength = 0
            /* 检测数据长度 */
            data_length = Int(Int32(revdata[20] & 0xff)
                | Int32(revdata[21] & 0xff) << 8
                | Int32(revdata[22] & 0xff) << 16
                | Int32(revdata[23] & 0xff) << 24);
            data_length = data_length - 256;
            //数据年月日
            data_year = CommonUtils.byte2Year(data: CommonUtils.copyofRange(data: revdata, from: 40, to: 43))
            data_month = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 44, to: 47))
            data_day = CommonUtils.byte2Day(data: CommonUtils.copyofRange(data: revdata, from: 48, to: 51))
            //开始时间
            data_starthh = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 52, to: 55))
            data_startmm = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 56, to: 59))
            data_startss = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 60, to: 63))
            //结束时间
            data_endhh = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 96, to: 99))
            data_endmm = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 100, to: 103))
            data_endss = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 104, to: 107))
        }else{
            revdata.removeSubrange(0..<8)
            revdata.remove(at: revdata.count-1)
            savelength += revdata.count
            if savelength <= data_length{
                savedata.append(contentsOf: revdata)
                progresslabel.text =  "\(savelength*100/data_length)%"
                self.SyncProgressView.progress = Float(savelength)/Float(data_length)
            }
            if savelength == data_length{
                print("数据传输完成")
                //存储文件
                self.savefile()
                savedata.removeAll()
                self.SyncProgressView.progress = 1.0
                self.SyncView.isHidden = true
                progresslabel.text = String.init(format: "%d%", 100)
            }
        }
        self.sendOKStatus()
        revdata.removeAll()
    }
    
//    func revbledata(data: [UInt8]) {
//        if data.count == 20{
//            if data[0] == 0x55 && data[1] == 0xAA && data[3] == 0x08{
//                hashead = true
//                length = Int(data[2])+3
//                revdata.removeAll()
//
//                isAnalysis = false
//                SyncTableView.isHidden = false
//                SyncView.isHidden = false
//
//            }
//        }
//        //结束指令
//        if data.count == 6{
//            if data[0] == 0x55 && data[1] == 0xAA && data[3] == 0x7F{
//                hashead = false
//                revdata.removeAll()
//                isAnalysis = false
//                self.SyncProgressView.progress = 0
//                SyncTableView.isHidden = true
//                SyncView.isHidden = true
//            }
//
//        }
//        if hashead{
//
//            for i in data{
//                revdata.append(i)
//                if revdata.count == length{
//                    if revdata[8] == 0x59 && revdata[9] == 0x72 && revdata[10] == 0x27 && revdata[11] == 0x95{
//                        isAnalysis = true
//                        self.SyncView.isHidden = false
//                        self.SyncProgressView.progress = 0
//                        progresslabel.text = String.init(format: "%d%", 0)
//                        savelength = 0
//                        /* 检测数据长度 */
//                        data_length = Int(Int32(revdata[20] & 0xff)
//                            | Int32(revdata[21] & 0xff) << 8
//                            | Int32(revdata[22] & 0xff) << 16
//                            | Int32(revdata[23] & 0xff) << 24);
//                        data_length = data_length - 256;
//                        //数据年月日
//                        data_year = CommonUtils.byte2Year(data: CommonUtils.copyofRange(data: revdata, from: 40, to: 43))
//                        data_month = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 44, to: 47))
//                        data_day = CommonUtils.byte2Day(data: CommonUtils.copyofRange(data: revdata, from: 48, to: 51))
//                        //开始时间
//                        data_starthh = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 52, to: 55))
//                        data_startmm = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 56, to: 59))
//                        data_startss = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 60, to: 63))
//                        //结束时间
//                        data_endhh = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 96, to: 99))
//                        data_endmm = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 100, to: 103))
//                        data_endss = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: revdata, from: 104, to: 107))
//
//                        isContinue = true
//                        sendOKStatus()
//                    }else{
//                        revdata.removeSubrange(0..<8)
//                        revdata.remove(at: revdata.count-1)
//                        savelength += revdata.count
//                        if savelength <= data_length{
//                            savedata.append(contentsOf: revdata)
//                            progresslabel.text =  "\(savelength*100/data_length)%"
//                            self.SyncProgressView.progress = Float(savelength)/Float(data_length)
//                        }
//                        if savelength == data_length{
//                            print("数据传输完成")
//                            //存储文件
//                            savefile()
//                            savedata.removeAll()
//                            self.SyncProgressView.progress = 1.0
//                            self.SyncView.isHidden = true
//                            progresslabel.text = String.init(format: "%d%", 100)
//                             sendOKStatus()
//
//                        }else{
//                            sendOKStatus()
//                        }
//
//
//
//                    }
//
//                     revdata.removeAll()
//                }
//            }
//
//        }
//
    
    
    let ecgdatadao : ECGDataDao = ECGDataDao.sharedInstance
    let dateformatter : DateFormatter = DateFormatter()
    var datanum = 0
    
    //保存文件
    func savefile(){
        let filedao : FiledocmDao = FiledocmDao()
        let enddatestr : String = String.init(format: "%d-%02ld-%02ld-%02ld-%02ld-%02ld", data_year,data_month,data_day,data_endhh,data_endmm,data_endss)
        
        let filename = filedao.createfilename(datastyle: 0, phone: phone, devicename: (BleTools.bindperipheral?.name)!,datestr: enddatestr)
       
        //数据库更新
        
        dateformatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        let enddate : Date = dateformatter.date(from: enddatestr)!
        let startdatestr : String = String.init(format: "%d-%02ld-%02ld-%02ld-%02ld-%02ld", data_year,data_month,data_day,data_starthh,data_startmm,data_startss)
        let startdate : Date = dateformatter.date(from: startdatestr)!
        let datestr : String = String.init(format: "%d-%02ld-%02ld", data_year,data_month,data_day)
        let data : ECGdata = ECGdata.init(date: datestr, enddate: enddate as NSDate, fileurl: filename, isupdate: false, startdate: startdate as NSDate, phone: phone,devicename:BleTools.bindperipheral?.name,deviceid: BleTools.bindperipheral?.identifier.uuidString)
        
        if filedao.savefile(ecgdata: savedata , filename: filename){
            ecgdatadao.create(data)
            print("数据保存成功")
        }
        tabledata.append("\(startdate)--\(enddate)")
        SyncTableView.reloadData()
        datanum += 1
        self.SyncLabel.text = "手表上传\(datanum)/\(FourViewController.updateecgdata)数据成功！"
        if datanum == Int(FourViewController.updateecgdata){
            datanum = 0
            hashead = false
            isContinue  = false
            isAnalysis  = false
            self.SyncView.isHidden = true
            NotificationCenter.default.post(name: Notification.Name("isclearupdata"), object: nil)
            FourViewController.updateecgdata = 0
           self.SyncLabel.text = "手表上传数据成功！"
        }
    }
    
    
    
    func sendOKStatus(){
        let bleorders : BleOrders = BleOrders()
        
        let senddata  = bleorders.myorder(cmd: SENDCMD.SendStateCmd, data: [WATCHSTATUS.STATUS_OK.rawValue])
        print(senddata)
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
    }

    
    

}
