//
//  FirstViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/14.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Alamofire

var filedao : FiledocmDao = FiledocmDao()
var ecgdatadao : ECGDataDao = ECGDataDao.sharedInstance

class FirstViewController: UIViewController ,NskAlgoSdkDelegate{

    @IBOutlet weak var batterymsglabel: UILabel!
    @IBOutlet weak var batteryitem: UIBarButtonItem!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var drawbackview: DrawBackView!
    @IBOutlet weak var drawlineview: DrawPointView!
    @IBOutlet weak var ECGSpeed: UILabel!
    @IBOutlet weak var AddRateLabel: UILabel!
    @IBOutlet weak var IndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var ConnBleBtn: UIButton!
    @IBOutlet weak var HeartRateLabel: UILabel!
    @IBOutlet weak var SizeBtn: UIButton!
    @IBOutlet weak var WaitIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var debug_SN: UILabel!
    @IBOutlet weak var debug_RSSI: UILabel!
    @IBOutlet weak var debug_CRC: UILabel!
    @IBOutlet weak var debug_q: UILabel!
    @IBOutlet weak var debug_RR: UILabel!
    @IBOutlet weak var debugview: UIView!
    @IBOutlet weak var BleStateLabel: UILabel!
    @IBOutlet weak var drawviewheight: NSLayoutConstraint!
    
    var time : Int = 0
    var sdkstate : NskAlgoState = .stop
    static var SAMPLERATE = 512
    var alogdata : [Int16] = []
    var ECGlist : [Int] = []//ECG数据
    var Sensorlist : Array<Int> = []//Sensor数据
    var ECGSensorlist : Array<Int> = [] //ECG+Sensor的混合原始数据，包含包序号
    var drawlist : Array<Int> = []//画线使用的数据
    var exitRawThread : Bool = true
    var timer , addtimer : Timer!
    var bindper : String!
    var bleorder : BleOrders = BleOrders()
    var nownum : Int = 0
    var beforenum : Int = 0
    var startdate : Date!
    var connstate : blestate = blestate.ble_disconn //连接状态
    var scale : Int = 10
    
    let dateFormatter = DateFormatter()
   
    static var phone : String!
    var birthday : String!
    var weight : Int!
    var height : Int!
    var gender : Int!
    var poorthread : Thread = Thread.init()
    
    var alogsdk : NskAlgoSdk = NskAlgoSdk.init()
    
    var isbind : Bool = false
    var isbleconn : Bool = false
    
    var algodata : [Int] = []
    var rawindex : Int = 0
    var datestr : String!
    var drawthread : Thread!
    
    var baoSN : Int = 1//包序号
    var alldata : Array<UInt8> = [] //Data部分的去处前四个字节包序号的部分
    var savedata : Data = Data()//进行保存的ECGSensor原始数据
    var baodata : [UInt8] = []//一包数据
    var beforeSN : Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //BleTools.sharedInstance.managerecgdelegate = self
        self.timelabel.isHidden = true
        drawlineview.backgroundColor = #colorLiteral(red: 1, green: 0.150029252, blue: 0, alpha: 0)//设置背景透明
        drawbackview.setNeedsDisplay()
        drawlineview.setNeedsDisplay()
        self.ConnBleBtn.isHidden = true
        self.debugview.isHidden = true
        self.debug_q.isHidden = true
        self.debug_RSSI.isHidden = true
        self.debug_SN.isHidden = true
        self.debug_CRC.isHidden = true
        let screenwidth = UIScreen.main.bounds.size.width
        drawviewheight.constant = CGFloat(11)*screenwidth/CGFloat(20)
        
        filedao = FiledocmDao.init()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        initAlgoSDK()
        
        initNotification()
        
        initView()
       
        addtimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addtime), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        MainController.isSendable = false
    }
    override func viewDidAppear(_ animated: Bool) {
        MainController.isSendable = true
    }
    //初始化view
    func initView() {
        batterymsglabel.isHidden = true
        if isbind {
            NotificationCenter.default.addObserver(self, selector: #selector(getblestate), name: Notification.Name("bleconn"), object: nil)
            switch BleTools.BTState{
                
            case .ble_on,.ble_disconn:
                BleStateLabel.isHidden = false
                BleStateLabel.text = "正在搜索..."
                ConnBleBtn.isHidden = true
                WaitIndicatorView.isHidden = false
                 BleTools.sharedInstance.scanDevice()
                if timer != nil{
                    timer.invalidate()
                    timer = nil
                }
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(connbinddevice), userInfo: nil, repeats: true)
            case .ble_off:
                BleStateLabel.isHidden = false
                ConnBleBtn.isHidden = false
                ConnBleBtn.setTitle("未连接", for: .normal)
                BleStateLabel.text = "蓝牙未打开，请打开蓝牙"
                WaitIndicatorView.isHidden = true
                
            case .ble_conn:
                WaitIndicatorView.isHidden = true
                BleStateLabel.isHidden = true
                ConnBleBtn.isHidden = false
                ConnBleBtn.setTitle("已连接", for: .normal)
                if timer != nil{
                    timer.invalidate()
                    timer = nil
                }
            default:
                break
            }
            
        }else{
            if self.connstate == blestate.ble_conn{
                if BleTools.bindperipheral != nil{
                    BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
                }
            }
             ConnBleBtn.isHidden = false
             BleStateLabel.isHidden = false
            BleStateLabel.text = "未绑定蓝牙设备"
            self.WaitIndicatorView.isHidden = true
            self.ConnBleBtn.isHidden = false
            ConnBleBtn.setTitle("未连接", for: .normal)
            let alert  = UIAlertController(title:"提示",message:"还未绑定设备,请先进行绑定",preferredStyle:.alert)
            let OKAction = UIAlertAction(title:"确定",style:.default){
                (alertAction) -> Void in
                self.performSegue(withIdentifier: "showbindview", sender: nil)
               
            }
            let cancelAction = UIAlertAction(title:"取消",style:.cancel){
                (alertAction) -> Void in
                 alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            alert.addAction(OKAction)
            self.present(alert,animated: true,completion: nil)
            
        }
    }

    //初始化通知
    func initNotification(){
        //连接的通知
        NotificationCenter.default.addObserver(self, selector: #selector(getbatterymsg(_:)), name: Notification.Name("batterymsg"), object: nil)
        //绑定取消的通知
        NotificationCenter.default.addObserver(self, selector: #selector(cancelbind), name: NSNotification.Name("bindcancel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(successbind), name: Notification.Name("successbind"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changedebugview(_:)), name: Notification.Name("isdebug"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRSSI(_:)), name: Notification.Name("reloadRSSI"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(getecgdata(_:)), name: Notification.Name("ecgdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeAction), name: Notification.Name("closeapp"), object: nil)
    }
    //打开debug页面的通知函数
    func changedebugview(_ notification : Notification){
        let isdebug = notification.object as! Bool
        if isdebug{
            self.debugview.isHidden = false
            self.debug_q.isHidden = false
             self.debug_RSSI.isHidden = false
             self.debug_SN.isHidden = false
             self.debug_CRC.isHidden = false
        }else{
            self.debugview.isHidden = true
            self.debug_q.isHidden = true
            self.debug_RSSI.isHidden = true
            self.debug_SN.isHidden = true
            self.debug_CRC.isHidden = true
        }
    }
    //更新RSSI通知的函数
    func reloadRSSI(_ notification : Notification){
      let RSSI = notification.object as! NSNumber
        self.debug_RSSI.text = String.init(format: "RSSI:%d", RSSI.intValue )
    }
    
    //初始化AlgoSDK
    func initAlgoSDK(){
        alogsdk = NskAlgoSdk.sharedInstance() as! NskAlgoSdk
        self.alogsdk.delegate = self
        let userdefaults : UserDefaults = .standard
        bindper = userdefaults.string(forKey: "bindper")
        if bindper != nil{
            isbind = true
        }
        FirstViewController.phone = userdefaults.string(forKey: "phone")!
        birthday = userdefaults.string(forKey: "birthday")
        height = userdefaults.integer(forKey: "height")
        weight = userdefaults.integer(forKey: "weight")
        gender = userdefaults.integer(forKey: "gender")
        
        let licensestr : String     = "NeuroSky_Release_To_GeneralFreeLicense_Use_Only_Dec  1 2016"
        var license : [CChar] = licensestr.cString(using: .utf8)!
        for _ in license.count ..< 128{
            license.append(0)
        }
        if alogsdk.setAlgorithmTypes(.ecgTypeHeartRate, licenseKey: &license) != 0{
            
            print("开启ALogSDK错误")
        }
        alogsdk.setSampleRate(NskAlgoDataType.ECG, sampleRate: NskAlgoSampleRate.rate512)
        
         configureProfile()
        
        alogsdk.setECGHRVAlgoConfig(30)
    }
    
    //获取电池信息
    func getbatterymsg(_ notification :Notification){
        let batterymsg = notification.object as! UInt8
        switch batterymsg {
        case 0:
            batteryitem.image = UIImage.init(named: "battery_empty.png")
            batterymsglabel.isHidden = false
        case 1:
            batterymsglabel.isHidden = true
            batteryitem.image = UIImage.init(named: "battery_one.png")
        case 2:
            batterymsglabel.isHidden = true
            batteryitem.image = UIImage.init(named: "battery_two.png")
        case 3:
            batterymsglabel.isHidden = true
            batteryitem.image = UIImage.init(named: "battery_full.png")
        case 4:
            batterymsglabel.isHidden = true
            batteryitem.image = UIImage.init(named: "battery_full.png")
        case +0x80:
            batterymsglabel.isHidden = true
            batteryitem.image = UIImage.init(named: "battery_charge.png")
        default:
            batterymsglabel.isHidden = true
            batteryitem.image = UIImage.init(named: "battery_charge.png")
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //ECGSDK配置
    func configureProfile(){
        //进行配置
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var profiles : Array<NskProfile> = alogsdk.getProfiles() as! Array<NskProfile>
        let profile : NskProfile = NskProfile.init()
        profile.userName = FirstViewController.phone
        if height != 0{
            profile.height = height
        }else{
            profile.height = 170
        }
        if weight != 0 && weight<200{
            profile.weight = weight
            
        }else{
            profile.weight = 70
            
        }
        if birthday != nil{
            profile.dob = dateFormatter.date(from: birthday!)
        }else{
            profile.dob = dateFormatter.date(from: "1991-01-01")
        }
        
        if gender == 0{
            profile.gender = true
        }else{
            profile.gender = false
        }
        profile.userId = 0
        self.alogsdk.update(profile)
        for p : NskProfile in profiles{
            self.alogsdk.deleteProfile(p.userId)
        }
        self.alogsdk.update(profile)
        profiles = alogsdk.getProfiles() as! Array<NskProfile>

        let activeProfile = profiles[0].userId;
        
        alogsdk.setActiveProfile(activeProfile)
       alogsdk.setProfileBaseline(activeProfile, type: .ecgTypeHeartRate, data: nil)
        
    }
  
    @IBAction func connblebtnAction(_ sender: UIButton) {
        switch sender.title(for: .normal) {
        case "未连接"?:
            if BleStateLabel.text == "未绑定蓝牙设备"{
                self.performSegue(withIdentifier: "showbindview", sender: nil)
            }
            if BleStateLabel.text == "蓝牙未打开，请打开蓝牙"{
                //蓝牙设置界面
                let bleurl = URL.init(string: "App-Prefs:root=Bluetooth")
                if UIApplication.shared.canOpenURL(bleurl!){
                    UIApplication.shared.canOpenURL(bleurl!)
                }
            }
        default:
            break
        }
    }
    //变换心电形式的幅度
    @IBAction func SizeBtnAction(_ sender: Any) {
        var s , btntitle : String!
        if scale < 40{
            scale = scale*2
            self.drawlineview.scale = Double(scale)
            s  = NSString(format:"增益：%dmm/mv",scale) as String
            btntitle = NSString(format:"X%d",scale/10) as String
            
        }else{
            scale = 10
            self.drawlineview.scale = Double(scale)
            s  = NSString(format:"增益：%dmm/mv",scale) as String
            btntitle = NSString(format:"X%d",scale/10) as String
            
        }
        self.SizeBtn.setTitle(btntitle, for: .normal)
        self.AddRateLabel.text = s
    }
    
   
    var errorCRC = 0
    var errorSN = 0
    //计数器工作，如果接受到心电数据开始计时
    func addtime()  {
        if BleTools.bindperipheral != nil{
            BleTools.bindperipheral?.readRSSI()
        }
        if nownum>0{
            
            
                
            self.timelabel.isHidden = false
            if self.sdkstate != .running{
                alogsdk.startProcess()
                exitRawThread = false
                if poorthread.isExecuting{
                    poorthread.cancel()
                }
                poorthread = Thread.init(target: self, selector: #selector(sendRawdata), object: nil)
                poorthread.start()
            }
            if nownum != beforenum{
                let nowdate = NSDate()
                time = Int(nowdate.timeIntervalSince1970-startdate.timeIntervalSince1970)
                self.timelabel.text = "测量中：\(getHHMMSSFormSS(seconds: time))"
                //测量2分钟的数据进行一次保存
                if savedata.count >= FirstViewController.SAMPLERATE*8*60*2*5/5{
                    saveECGDate()
                }
                beforenum = nownum
            }else{
     
                self.timelabel.isHidden = true
                self.alldata.removeAll()
                self.drawlist.removeAll()
                self.baodata.removeAll()
                beforenum = 0
                nownum = 0
                errorSN = 0
                errorCRC = 0
                beforeSN = 0
                baoSN = 0
                time = 0
                rawindex = 0
                alogsdk.pauseProcess()
                exitRawThread = true
                saveECGDate()
                self.Sensorlist.removeAll()
                self.ECGlist.removeAll()
                self.ECGSensorlist.removeAll()
                HeartRateLabel.text = "实时心率：--- bpm"

                self.drawlineview.drawData = []
                self.drawlineview.setNeedsDisplay()
            }
        }else{
            self.timelabel.isHidden = true
            self.ECGlist.removeAll()
            HeartRateLabel.text = "实时心率：--- bpm"
            rawindex = 0
            errorSN = 0
            errorCRC = 0
            beforeSN = 0
            baoSN = 0

        }
        sendpowercmd()
        
    }
    
    //定期执行的操作
    func sendpowercmd(){
        
        if BleTools.BTState == .ble_conn {
          
            if MainController.BINDPER != nil && MainController.isSendable {
                 BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorder.myorder(cmd: SENDCMD.WatchBatteryCmd, data: nil)) )
            }
        }else{
            batteryitem.image = UIImage.init(named: "battery_default.png")
        }
    }
    
    //声明方法将秒数转为 分:秒
    func getHHMMSSFormSS(seconds:Int) -> String {
        //let str_hour = NSString(format: "%02ld", seconds/3600)
        let str_minute = NSString(format: "%02ld", (seconds%3600)/60)
        let str_second = NSString(format: "%02ld", seconds%60)
        let format_time = NSString(format: "%@:%@",str_minute,str_second)
        return format_time as String
    }
    
 
    //实现对绑定设备的连接
    func connbinddevice(){
        
        let userdefaults : UserDefaults = .standard
        bindper = userdefaults.string(forKey: "bindper")
        if bindper != nil {
            print(BleTools.BTState )
            if BleTools.BTState == blestate.ble_conn{
                getblestate()
                return
            }
            if BleTools.BTState != blestate.ble_conn {
                print(self.bindper)
                if BleTools.peripheralArray.count > 0{
                    print(BleTools.peripheralArray.count)
                    var sortArray = BleTools.deviceArray
                    sortArray.sort { (device1, device2) -> Bool in
                        if device1.rssi.intValue > device2.rssi.intValue{
                            return true
                        }else{
                            return false
                        }
                    }
                    
                    for i in 0 ..< sortArray.count{
                        if sortArray[i].peripheral.identifier.uuidString == self.bindper{
                            BleTools.sharedInstance.connectDevice(per: sortArray[i].peripheral)
                            break
                        }
                    }
                    BleTools.peripheralArray.removeAll()
                }else{
                    BleTools.sharedInstance.scanDevice()
                }
            }
        }
    }

    //得到蓝牙连接的状态
    func getblestate() {
        connstate = BleTools.BTState
       initView()
    }
    
    //绑定设备取消
    func cancelbind(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("bleconn"), object: nil)
        isbind = false
        bindper = nil
        initView()
    }
    //成功绑定设备的通知
    func successbind(){
        NotificationCenter.default.addObserver(self, selector: #selector(getblestate), name: Notification.Name("bleconn"), object: nil)
        isbind = true
        let userdefaults : UserDefaults = .standard
        bindper = userdefaults.string(forKey: "bindper")
        if bindper != nil{
            isbind = true
        }else{
            isbind = false
        }
        initView()
    }
    
    func closeAction(){
        removeNotification()
        self.dismiss(animated: true, completion: nil)
    }
    
    //得到心电数据包的通知
    func getecgdata(_ notification : Notification){

        self.baodata.removeAll()
        self.Sensorlist.removeAll()
        self.ECGSensorlist.removeAll()
        var samplefreq = 0
        (samplefreq, baodata) = notification.object as! (Int,[UInt8])
        FirstViewController.SAMPLERATE = samplefreq
        print("一包数据：\(baodata)")
        self.baoSN = Int(baodata[4]) + Int(baodata[5])*(2^8) + Int(baodata[6])*(2^16) + Int(baodata[7])*(2^24)
        if beforeSN == 0{
            beforeSN = baoSN
        }
        if beforeSN > 0 && baoSN-beforeSN > 0{
            self.errorSN = errorSN+(baoSN-beforeSN)-1
            self.debug_SN.text = String.init(format: "SN:%d", errorSN)
        }
        self.beforeSN = self.baoSN
        print("第\(baoSN)包数据")
        self.baodata.removeSubrange(0..<8)
        self.baodata.removeLast()
        for s in baodata{
            self.alldata.append(s)
        }
        self.alldata = analysisdata(data: alldata)
        self.baodata.removeAll()
        self.ECGSensorlist.removeAll()
        self.Sensorlist.removeAll()

    }

    //分解数据
    func analysisdata(data : Array<UInt8>) -> Array<UInt8> {
        if nownum == 0{
            startdate = Date()
        }
        var alldata = data
        let k : Int = Int(ceil(Double(alldata.count/16)))
        if k > 0{
            for _ in 0 ... k{
                if alldata.count>=16{
                    for m  in 0 ..< 8{
                        var perdata =  (Int16(alldata[m*2+1]) & 0xff) << 8  | ((Int16(alldata[m*2]) & 0xff))//将两个8位数据组合
                        self.ECGSensorlist.append(Int(perdata))
                        self.savedata.append(contentsOf: CommonUtils.Int2bigEndian(num: perdata))
                        if m < 5 {
                            if  rawindex >= 5120{
                                ECGlist.removeSubrange(0..<5120)
                                algodata.removeSubrange(0..<5120)
                                rawindex = 0
                            }
                            if FirstViewController.SAMPLERATE == 256{
                               
                                if ECGlist.count > 0{
                                    self.ECGlist.append((Int(perdata)+ECGlist.last!)/2)
                                }else{
                                    self.ECGlist.append(Int(perdata))
                                }
                                self.ECGlist.append(Int(perdata))
                            }else{
                                self.ECGlist.append(Int(perdata))
                            }
                           
                            self.drawlist.append(Int(perdata))
                            if FirstViewController.SAMPLERATE == 512{
                                //reloadlineview()
                                self.perform(#selector(reloadlineview), with: nil, afterDelay: 0.0018)
                            }
                            if FirstViewController.SAMPLERATE == 256{
                                //reloadlineview()
                                self.perform(#selector(reloadlineview), with: nil, afterDelay: 0.004)
                            }

                            
                        }else{
                            self.Sensorlist.append(Int(perdata))
                        }
                    }
                    
                    alldata.removeSubrange(0..<16)
                }else{
                    break
                }
            }
        }else{
             return alldata
        }
                return alldata
    }
    //绘制心电图
    func reloadlineview(){
         nownum += 1
        self.drawlineview.adddata(perdata: drawlist.first!)
        drawlist.removeFirst()
    }
    
    //保存数据到数据库和文件中
    func saveECGDate(){
        dateFormatter.dateFormat = "yyyy-MM-dd"
        datestr = dateFormatter.string(from: Date())
        
        //先上传数据
        if savedata.count >= 512{
            var enddate = Date()
            if BleTools.bindperipheral != nil{
                if AppDelegate.netstyle != .notReachable{
                    var filedata = savedata
                    netUtil.sharedInstance.uploadECGfile(startdate:startdate , enddate: enddate, mode: 1, bodyStatus: 1, deviceSN: BleTools.DEVICEMAC, phone: FirstViewController.phone, deviceType: 1, filedata: filedata, logFiledata: nil, signalQualityFile: nil,frequency: FirstViewController.SAMPLERATE)
                    savedata.removeAll()
                }else{
                    netUtil.sharedInstance.saveECGdata(startdate, Date(), false, 0, savedata)
                    savedata.removeAll()
                }
            }else{
                ToastView.instance.showToast(content: "蓝牙连接错误，数据未存储！")
            }
            startdate = Date()
           
        }else{
            ToastView.instance.showToast(content: "测量时间太短！数据不保存")
        }
    }
    
    
    //将数据传给ALgoSDK
    func sendRawdata(){
        if ECGlist.count == 0{
            return
        }else{
            algodata = ECGlist
        }
         //fill the pq first
        while !exitRawThread {
            algodata = ECGlist
            if rawindex == 0 || rawindex % 200 == 0{
                var poorsignal : [Int16] = [200]
                self.alogsdk.dataStream(.ECGPQ, data: &poorsignal, length: 1)
            }
            //fill raw into SDK
            let ECGcount = algodata.count
            if ECGcount-1 > rawindex{
                var eeg_data : [Int16] = [Int16(algodata[rawindex])]
                self.alogsdk.dataStream(.ECG, data: &eeg_data, length: 1)
                 rawindex += 1
                
              }
            usleep(200)
        }
        
    }
    
    //NskAlgoSdkDelegate方法
    func stateChanged(_ state: NskAlgoState, reason: NskAlgoReason) {
        print(state)
        self.sdkstate = state
    }
    func ecgAlgoValue(_ ecg_value_type: NskAlgoECGValueType, ecg_value ecg_valid: NSNumber!, ecg_valid ECG_valid: Bool) {
        
        if signalquality == .poor{
            self.HeartRateLabel.text = "实时心率： --- bpm"
            self.debug_q.text = "心电质量:差"
        }else{
           
            self.debug_q.text = "心电质量:优"
            switch ecg_value_type {
            case .ecgValueTypeHeartRate:
                print("心跳频率\(ecg_valid.intValue)")
                HeartRateLabel.text = "实时心率： \(ecg_valid.intValue) bpm"
            default :
                break
            }
        }
        
    }
    var signalquality : NskAlgoSignalQuality = .poor
    func ecgHRVFDAlgoValue(_ hf: NSNumber!, lf: NSNumber!, lfhf_ratio: NSNumber!, hflf_ratio: NSNumber!) {
 
    }
    func ecgHRVTDAlgoValue(_ nn50: NSNumber!, sdnn: NSNumber!, pnn50: NSNumber!, rrTranIndex: NSNumber!, rmssd: NSNumber!) {
        self.debug_RR.text = String.init(format: "RR间期:%d", rrTranIndex.intValue)
    }
    func signalQuality(_ signalQuality: NskAlgoSignalQuality) {
        signalquality = signalQuality
    }
    func overallSignalQuality(_ signalQuality: NSNumber!) {
        
    }
    
    func removeNotification(){
        addtimer.invalidate()
        addtimer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
}
