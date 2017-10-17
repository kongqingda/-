//
//  FirstViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/14.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController ,NskAlgoSdkDelegate,ManagerECGdataDelegate{

    @IBOutlet weak var batteryitem: UIBarButtonItem!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var drawbackview: DrawBackView!
    @IBOutlet weak var drawlineview: DrawLineView!
    @IBOutlet weak var ECGSpeed: UILabel!
    @IBOutlet weak var AddRateLabel: UILabel!
    @IBOutlet weak var IndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var ConnBleBtn: UIButton!
    @IBOutlet weak var HeartRateLabel: UILabel!
    @IBOutlet weak var SizeBtn: UIButton!
    @IBOutlet weak var WaitIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var drawviewheight: NSLayoutConstraint!
    var alogdata : [Int16] = []
    var ECGlist : [Int] = []//ECG数据
    var Sensorlist : Array<Int> = []//Sensor数据
    var ECGSensorlist : Array<Int> = [] //ECG+Sensor的混合原始数据，包含包序号
    var drawlist : Array<Int> = []//画线使用的数据
    var exitRawThread : Bool = true
    var timer , addtimer : Timer!
    var bindper : String!
    var bleorder : BleOrders = BleOrders()
    var main = MainController()
    var nownum : Int = 0
    var beforenum : Int = 0
    var startdate : Date!
    var connstate : blestate = blestate.ble_disconn //连接状态
    var scale : Int = 10
    
    let dateFormatter = DateFormatter()
    var filedao : FiledocmDao = FiledocmDao()
    var ecgdatadao : ECGDataDao = ECGDataDao()
    static var phone : String!
    var birthday : String!
    var weight : Int!
    var height : Int!
    var gender : Int!
    var poorthread : Thread = Thread.init()
    
    var alogsdk : NskAlgoSdk = NskAlgoSdk.init()
    
    var netutil : netUtil = netUtil()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        filedao = FiledocmDao.init()
        ecgdatadao = ECGDataDao.sharedInstance
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        initAlgoSDK()
        
        initNotification()
        
        if bindper != nil {
            print("已经有绑定设备")
            BleTools.sharedInstance.scanDevice()
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(connbinddevice), userInfo: nil, repeats: true)
        }else{
            self.WaitIndicatorView.isHidden = true
            self.ConnBleBtn.isHidden = false
            ConnBleBtn.setTitle("未连接", for: .normal)
            let alert  = UIAlertController(title:"提示",message:"还未绑定设备请先绑定",preferredStyle:.alert)
            let OKAction = UIAlertAction(title:"确定",style:.cancel){
                (alertAction) -> Void in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(OKAction)
            self.present(alert,animated: true,completion: nil)
           
        }
        addtimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addtime), userInfo: nil, repeats: true)

    }
    //初始化view
    func initView() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        BleTools.sharedInstance.managerecgdelegate = self
        self.timelabel.isHidden = true
        netutil = netUtil.sharedInstance
        //self.main.bletools.managerdelegate = self
        drawlineview.backgroundColor = #colorLiteral(red: 1, green: 0.150029252, blue: 0, alpha: 0)//设置背景透明
        drawbackview.setNeedsDisplay()
        drawlineview.setNeedsDisplay()
        self.ConnBleBtn.isHidden = true
        
        let screenwidth = UIScreen.main.bounds.size.width
        drawviewheight.constant = CGFloat(11)*screenwidth/CGFloat(20)
    }

    //初始化通知
    func initNotification(){
        //连接的通知
        NotificationCenter.default.addObserver(self, selector: #selector(getblestate), name: Notification.Name("bleconn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getbatterymsg(_:)), name: Notification.Name("batterymsg"), object: nil)
        //绑定取消的通知
        NotificationCenter.default.addObserver(self, selector: #selector(cancelbind), name: NSNotification.Name("bindcancel"), object: nil)
    }
    
    
    //初始化AlgoSDK
    func initAlgoSDK(){
        alogsdk = NskAlgoSdk.sharedInstance() as! NskAlgoSdk
        self.alogsdk.delegate = self
        let userdefaults : UserDefaults = .standard
        bindper = userdefaults.string(forKey: "bindper")
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
        case 1:
            batteryitem.image = UIImage.init(named: "battery_one.png")
        case 2:
            batteryitem.image = UIImage.init(named: "battery_two.png")
        case 3:
            batteryitem.image = UIImage.init(named: "battery_full.png")
        case 4:
            batteryitem.image = UIImage.init(named: "battery_full.png")
        case +0x80:
            batteryitem.image = UIImage.init(named: "battery_charge.png")
        default:
            batteryitem.image = UIImage.init(named: "battery_charge.png")
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        if weight != 0{
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
    
    var time : Int = 0
    var sdkstate : NskAlgoState = .stop
    
    //计数器工作，如果接受到心电数据开始计时
    func addtime()  {
        if nownum>0{
            
            self.timelabel.isHidden = false
            if self.sdkstate != .running{
                alogsdk.startProcess()
                exitRawThread = false
                poorthread = Thread.init(target: self, selector: #selector(sendRawdata), object: nil)
                poorthread.start()
            }
            if nownum != beforenum{
                let nowdate = NSDate()
                time = Int(nowdate.timeIntervalSince1970-startdate.timeIntervalSince1970)
                self.timelabel.text = "测量中：\(getHHMMSSFormSS(seconds: time))"
                beforenum = nownum
            }else{
                ishashead  = false
                isanalysis = false
                isContinue = true
                isDraw = false
                self.timelabel.isHidden = true
                self.alldata.removeAll()
                self.drawlist.removeAll()
                self.baodata.removeAll()
                beforenum = 0
                nownum = 0
                time = 0
                rawindex = 0
                alogsdk.pauseProcess()
                exitRawThread = true
                saveECGDate()
                savedata.removeAll()
                self.Sensorlist.removeAll()
                self.ECGlist.removeAll()
                self.ECGSensorlist.removeAll()
               HeartRateLabel.text = "实时心率：--- bpm"
                self.ishashead = false
                self.drawlineview.drawData = []
                self.drawlineview.setNeedsDisplay()
            }
        }else{
            self.timelabel.isHidden = true
            self.ECGlist.removeAll()
            HeartRateLabel.text = "实时心率：--- bpm"
            rawindex = 0
        }
        sendcmd()
        
    }
    //定期执行的操作
    func sendcmd(){
        
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
                    for i in 0 ..< BleTools.peripheralArray.count{
                        if BleTools.peripheralArray[i].identifier.uuidString == self.bindper{
                            BleTools.sharedInstance.connectDevice(per: BleTools.peripheralArray[i])
                            break
                            
                        }else{
                            BleTools.peripheralArray.remove(at: i)
                            BleTools.deviceArray.remove(at: i)
                            break
                        }
                    }
                    
                }else{
                    BleTools.sharedInstance.scanDevice()
                }
            }
        }
        
    }
    
    //得到蓝牙连接的状态
    func getblestate() {
        connstate = BleTools.BTState
        sendcmd()
        if connstate != blestate.ble_conn{
            self.ConnBleBtn.setTitle("未连接", for: .normal)
            BleTools.sharedInstance.scanDevice()
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(connbinddevice), userInfo: nil, repeats: true)
        }else{
          //  self.main.bletools.managerdelegate = self
            self.ConnBleBtn.isHidden = false
            ConnBleBtn.setTitle("已连接", for: .normal)
            self.WaitIndicatorView.isHidden = true
            BleTools.sharedInstance.stopScanDevice()
            if self.timer != nil{
                self.timer.invalidate()
                self.timer = nil
            }
            
        }

    }
    
    //绑定设备取消
    func cancelbind(){
        if self.connstate == blestate.ble_conn{
            if BleTools.bindperipheral != nil{
                 BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
            }
           
        }
        self.ConnBleBtn.setTitle("未连接", for: .normal)
        //self.timer.invalidate()
        let alert  = UIAlertController(title:"提示",message:"设备解除了绑定，请重新绑定！",preferredStyle:.alert)
        let OKAction = UIAlertAction(title:"确定",style:.cancel){
            (alertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(OKAction)
        self.present(alert,animated: true,completion: nil)
    }
    
    
    var isanalysis : Bool = false
    var datastream : Array<UInt8> = [] // 一个包的输入 200个字节
    var headdata : Array<UInt8> = [] //头文件判断，两个字节
    var length : Int = 0//数据长度
    var baonum : Int = 20//包数
    var currenbao : Int = 1//当前包
    var baoSN : Int = 1//包序号
    var alldata : Array<UInt8> = [] //Data部分的去处前四个字节包序号的部分
    var isecgdata = false
    var firstnum : Int = 0
    var sensornum : Int = 1
    var isContinue : Bool = true
    var isDraw : Bool = false
    var beforedata : [UInt8] = []
    var ishashead : Bool = false//受否检测到新包头
    var isnum : Int = 1
    var filename : String = ""
    var savedata : Data = Data()//进行保存的ECGSensor原始数据
    
 /**实现蓝牙数据通知的解析函数
    func revbledata(notification: Notification) {
        let data = notification.object as! Array<UInt8>
        print("开始解析数据")
        var nowdata = data
        if ishead(data: data) {
             print("检测到协议头")
            firstnum = data.index(of: 0x55)!
            if firstnum<data.count-8{
                if data[firstnum+1] == 0xAA && data[firstnum+3] == 0x07{
                    isanalysis = true
                    isContinue = false
                    length = Int(data[firstnum+2])
                    baoSN = Int(data[firstnum+4]) + Int(data[firstnum+5])*(2^8) + Int(data[firstnum+6])*(2^16) + Int(data[firstnum+7])*(2^24)
                    nowdata = data
                    currenbao = 1
                    
                    print("该数据为心电显示数据头1")
                }else{
                    isanalysis = false
                    isContinue = true
                }
            }else{
                isanalysis = true
                isContinue = true
                isnum = 1
                
            }

        }else{
            isanalysis = false
            isContinue = false
        }
        //收到头文件，进行下一步解析
        if (isanalysis){
            
            if isContinue && isnum == 2{
                for d in data {
                    beforedata.append(d)
                }
                 firstnum = beforedata.index(of: 0x55)!
                if beforedata[firstnum+1] == 0xAA && beforedata[firstnum+3] == 0x07{
                    isanalysis = true
                    isContinue = false
                    length = Int(beforedata[firstnum+2])
                    baoSN = Int(beforedata[firstnum+4]) + Int(beforedata[firstnum+5])*(2^8) + Int(beforedata[firstnum+6])*(2^16) + Int(beforedata[firstnum+7])*(2^24)
                    nowdata = beforedata
                    currenbao = 1
                    print("该数据为心电显示数据头2")
                }else{
                    isanalysis = false
                    isContinue = true
                    datastream.removeAll()
                    alldata.removeAll()
                    ishashead = false
                    isnum = 1
                    
                }
                
            }
            if !isContinue{
                isnum = 1
                self.Sensorlist.removeAll()
                self.ECGSensorlist.removeAll()
                print("判断协议头位置")
                if firstnum>0 {
                    for n in 0 ..< firstnum{
                        datastream.append(data[n])
                        alldata.append(data[n])
                        
                    }
                    if ishashead{
                    alldata = draw(data: alldata)
                    }
                    nowdata.removeSubrange(0..<firstnum)
                }else{
                    nowdata = data
                }
                
               datastream.removeAll()
                alldata.removeAll()
                ishashead = true
            }
            for s in 0..<nowdata.count{
                datastream.append(nowdata[s])
                if s > 7{
                    alldata.append(nowdata[s])
                }
            }
            
            //alldata = draw(data: alldata)
            print("第一包长\(datastream.count)")
            

        }
        if !isanalysis && ishashead {
            currenbao += 1
            print("当前包\(currenbao)")
            
            for d in data {
                datastream.append(d)
                alldata.append(d)
            }
            
            alldata = draw(data: alldata)
            print("当前包\(datastream.count)")
            if(datastream.count == 200){
                print("已经完成一包数据的解析和显示，进行校验")
                // 保存文件
                datastream.removeSubrange(0..<8)
                savedata.append(contentsOf: datastream)
                
            }
        }
        beforedata = nowdata
        isnum = 2
    }**/
    var baodata : [UInt8] = []//一包数据
    //ManagerECGdataDelegate的方法
    func revECGdata(data: [UInt8]) {
        //检测是否丢包
        if self.baodata.count == 201{
            print("一包数据：\(baodata)")
            self.baoSN = Int(baodata[4]) + Int(baodata[5])*(2^8) + Int(baodata[6])*(2^16) + Int(baodata[7])*(2^24)
            if bleorder.ischeck(baodata){
                self.baodata.removeSubrange(0..<8)
                self.baodata.removeLast()
                for s in baodata{
                    self.alldata.append(s)
                }
                self.alldata = draw(data: alldata)
                self.savedata.append(contentsOf: baodata)
                
            }
            self.baodata.removeAll()
            self.ECGSensorlist.removeAll()
            self.Sensorlist.removeAll()
            self.ishashead = false
        }
        if self.baodata.count > 201{
            self.baodata.removeAll()
            self.ishashead = false
            print("包传输错误")
            self.ECGSensorlist.removeAll()
             self.Sensorlist.removeAll()
        }
        if self.ishashead{
            for s in data{
                self.baodata.append(s)
            }
        }
        //检测包头
        if data.count == 20 && data[0] == 0x55 && data[1] == 0xAA && data[3] == 0x07{
            print("检测到包头")
            self.baodata.removeAll()
            self.Sensorlist.removeAll()
            self.ECGSensorlist.removeAll()
            for s in data{
               self.baodata.append(s)
            }
            
            self.ishashead = true
        }
       
        
    }
    
  
    //画线
    func draw(data : Array<UInt8>) -> Array<UInt8> {
        if nownum == 0{
            startdate = Date()
            filename = filedao.createfilename(datastyle: 0, phone: FirstViewController.phone, devicename: (BleTools.bindperipheral?.name)!, datestr: nil)
        }
        var alldata = data
        let k : Int = Int(ceil(Double(alldata.count/16)))
        nownum += 1
        if k > 0{
            for _ in 0 ... k{
                if alldata.count>=16{
                    
                    for m  in 0 ..< 8{
                        var perdata =  (Int16(alldata[m*2+1]) & 0xff) << 8  | ((Int16(alldata[m*2]) & 0xff))//将两个8位数据组合
                        self.ECGSensorlist.append(Int(perdata))
                        if m < 5 {
                            if  rawindex >= 5120{
                                ECGlist.removeSubrange(0..<rawindex)
                                algodata.removeSubrange(0..<rawindex)
                                rawindex = 0
                            }
                            self.ECGlist.append(Int(perdata))
                            if self.drawlist.count <= self.drawlineview.widthmax{
                                self.drawlist.append(Int(perdata))
                            }else{
                                self.drawlist.removeAll()
                            }
                            self.drawlineview.drawData = self.drawlist
                            self.drawlineview.setNeedsDisplay()
                            
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
    
    
    func ishead(data : [UInt8]) -> Bool {
        if data.contains(0x55) && data .contains(0xAA){
            let first : Int = data.index(of: 0x55)!
            if first < (data.count-1){
                if data[first+1] == 0xAA{
                    return true
                }
            }
            
        }
        return false
    }
    
    //保存数据到数据库和文件中
    func saveECGDate(){
        
       
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let datestr = dateFormatter.string(from: date)
        var isupdate : Bool = false
        //先上传数据
        if AppDelegate.netstyle != .notReachable{
            isupdate = netutil.uploadECGfile(startTime: Int(1000*startdate.timeIntervalSince1970), endTime: Int(1000*date.timeIntervalSince1970), mode: 1, bodyStatus: 1, deviceSN: BleTools.DEVICESN, phone: FirstViewController.phone, deviceType: 1, filedata: savedata, logFiledata: nil, signalQualityFile: nil)
            
        }
        //filedao.savefile(ecgdata: ecgdata, filename: filename)
        if BleTools.bindperipheral != nil{
            let data : ECGdata = ECGdata.init(date: datestr, enddate: date as NSDate, fileurl: filename, isupdate: isupdate, startdate: startdate! as NSDate, phone: FirstViewController.phone,devicename:BleTools.bindperipheral?.name,deviceid: BleTools.bindperipheral?.identifier.uuidString)
            if filedao.savefile(ecgdata: savedata, filename: filename){
                ecgdatadao.create(data)
                print("数据保存成功")
            }
        }else{
            ToastView.instance.showToast(content: "蓝牙连接错误，数据未存储！")
        }
        
    }
    

   
   
    var algodata : [Int] = []
    var rawindex : Int = 0
    
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
            
//            if ECGcount-1 > 0{
//                var eeg_data : [Int16] = [Int16(algodata[0])]
//                self.alogsdk.dataStream(.ECG, data: &eeg_data, length: 1)
//                self.ECGlist.remove(at: 0)
//                rawindex += 1
//            }
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
            HeartRateLabel.text = "实时心率： -- bpm"
        }else{
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
      
    }
    func signalQuality(_ signalQuality: NskAlgoSignalQuality) {
        signalquality = signalQuality
    }
    func overallSignalQuality(_ signalQuality: NSNumber!) {
        
    }
    
}
