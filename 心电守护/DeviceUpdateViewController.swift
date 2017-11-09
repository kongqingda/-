//
//  DeviceUpdateViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
// 固件升级

import UIKit

class DeviceUpdateViewController: UIViewController {

    @IBOutlet weak var currVerlabel: UILabel!
    @IBOutlet weak var newVerlabel: UILabel!
    @IBOutlet weak var updateinderlabel: UILabel!
    @IBOutlet weak var databaoimage: UIImageView!
    @IBOutlet weak var updateimage: UIImageView!
    @IBOutlet weak var UpdateView: UIView!
    @IBOutlet weak var UpdateLabel: UILabel!
    @IBOutlet weak var UpdateProgressView: UIProgressView!
    @IBOutlet weak var UpdateBtn: UIButton!
    @IBOutlet weak var updateview: UIView!
    var downdata : Data = Data()
    let bleorders = BleOrders()
    var downurl : String!
    var firmwareVersion : String!
    var filesize : Int = 0
    var timer : Timer!
    var isstartupdate : Bool = false //是否进入升级模式
    var sendbaonum : Int = 0 //当前发送的的数据包数
    var sendbaocount : Int = 192 //当前发送的包的大小
    var isupdate : Bool = false //检查是否需要升级
    var isupdating : Bool = false //正在升级中
    var currentSR : String = "当前手表固件版本为1.0" //当前手表固件版本
    var sendthread : Thread! //发送的线程
    var issendding : Bool = false //正在发送中
    var revTime : TimeInterval = 0
    var addtimer : Timer!
    var sendtimer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Do any additional setup after loading the view.
        initNotification()
        initdata()
        initview()
        
    }
    //初始化通知
    func initNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(getFirmware(_:)), name: Notification.Name("getFirmware"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(devicedownload(_:)), name: Notification.Name("devicedownload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedata(_:)), name: Notification.Name("updatedata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendbao), name: Notification.Name("sendbao"), object: nil)
        
    }
    //解除通知
    func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("getFirmware"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("devicedownload"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updatedata"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("sendbao"), object: nil)
    }
    
    //初始化数据
    func initdata(){
        MainController.isSendable = false
        var type : String = "1"
        if AppDelegate.netstyle != .notReachable{
            if BleTools.BTState == .ble_conn{
                switch BleTools.bindperipheral?.name{
                    case "TH802"?:
                        type = "1"
                    case "TH902"?:
                        type = "2"
                    default:
                        break
                    }
              
                    netUtil.sharedInstance.getFirmware(type: type, mcufirwareVersion: BleTools.SOFTVERSION)
            
            }else{
                
                ToastView.instance.showAlert("请检查蓝牙连接", self)
            }
        
        }else{
            
            ToastView.instance.showAlert("请检查网络连接", self)
        }
    }
    //初始化界面
    func initview() {
        currentSR = "当前手表固件版本:"+BleTools.SOFTVERSION
         databaoimage.isHidden = true
        if isupdate{
            UpdateBtn.isHidden = false
            self.UpdateLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            if isupdating{
                self.updateview.isHidden = false
                self.updateimage.isHidden = false
                self.newVerlabel.isHidden = true
                self.currVerlabel.isHidden = true
                self.UpdateLabel.isHidden = false
                self.UpdateLabel.text = "正在升级中..."
                
            }else{
                self.newVerlabel.isHidden = false
                self.currVerlabel.isHidden = false
                self.UpdateLabel.isHidden = false
                self.updateview.isHidden = true
                self.updateimage.isHidden = true
                self.currVerlabel.text = currentSR
                self.newVerlabel.text = "最新手表固件版本:"+firmwareVersion
                self.UpdateLabel.text = "固件版本需要更新,点击升级"
            }
           
        }else{
            self.newVerlabel.isHidden = false
            self.currVerlabel.isHidden = false
             UpdateBtn.isHidden = true
            self.updateview.isHidden = true
            self.updateimage.isHidden = true
            self.UpdateLabel.isHidden = true
            self.UpdateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.currVerlabel.text = currentSR
            self.newVerlabel.text = "当前版本为最新版本"
        }
    }
    
    //重复动画
    func repeatAnimation(){
        databaoimage.layer.removeAllAnimations()
         databaoimage.layer.add(AnimationUtil.getImagedataAnimation(), forKey: "animation")
    }
    
    override
    func viewWillDisappear(_ animated: Bool) {
        MainController.isSendable = true
        self.isupdating = false
        self.issendding = false
        self.isstartupdate = false
        removeNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //升级点击事件
    @IBAction func UpdateBtnAction(_ sender: Any) {
        isupdating = true
        initview()
        UpdateBtn.isHidden = true
        netUtil.sharedInstance.devicedownload(fileurl:downurl)
    }
    //关闭点击事件
    @IBAction func closeaction(_ sender: Any) {
        if isstartupdate{
            let alert  = UIAlertController.init(title: "警告", message: "手表正在升级中，退出会造成升级失败，是否仍然退出", preferredStyle: UIAlertControllerStyle.alert)
            let okaction = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.destructive, handler: { (uialert) in
                self.dismiss(animated: true) {
                    BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
                }
            })
            let cancelaction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.default, handler: { (uialert) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okaction)
            alert.addAction(cancelaction)
            self.present(alert, animated: true, completion: nil)
        }else{
            //BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
            bletools.readSoftVersion()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //固件版本的通知
    func getFirmware(_ notification: Notification) {
        let json  = notification.object as! NSDictionary
        let info = json["info"] as! NSArray
        let infodata = info[info.count-1] as! NSDictionary
        self.firmwareVersion = infodata["firmwareVersion"] as! String
        self.filesize = infodata["size"] as! Int
        self.downurl = infodata["downUrl"] as! String
         self.firmwareVersion =  self.firmwareVersion.replacingOccurrences(of: "H", with: "")
        var newArray = firmwareVersion.components(separatedBy: "_")
        var currentArray = BleTools.SOFTVERSION.components(separatedBy: "_")
        var cstr0 = currentArray[0]
        var cstr1 = currentArray[1]
        var cstr2 = "20"+currentArray[2]
        var nstr0 = newArray[0]
        var nstr1 = newArray[1]
        var nstr2 = newArray[2]
        nstr1.remove(at: nstr1.startIndex)
        cstr1.remove(at: cstr1.startIndex)
        if cstr0 == nstr0 && cstr1 == nstr1 && cstr2 == nstr2{
                isupdate = false
        }else{
            isupdate = true
        }
        isupdating = false
        initview()
    }
    
    func devicedownload(_ notification: Notification) {
        downdata  = notification.object as! Data
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(repeatAnimation), userInfo: nil, repeats: true)
        databaoimage.layer.add(AnimationUtil.getImagedataAnimation(), forKey: "animation")
        databaoimage.isHidden = false
        let senddata  = self.firmwareVersion.data(using: String.Encoding.utf8)
         BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.MCUCmd3, data: [UInt8](senddata!))) )
        self.revTime = Date().timeIntervalSince1970
        addtimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addtime), userInfo: nil, repeats: true)
    }
    
    var isContinue : Bool = true
    //发送数据的通知
    func updatedata(_ notification : Notification){
        let revdata = notification.object as! [UInt8]
        
        self.revTime = Date().timeIntervalSince1970
        
        switch revdata[4] {
        case 0x00:
            if !isstartupdate{
                isstartupdate = true
                sendfirstbao()
            }else{
                sendfirstbao()
            }
            print("发送第一包")
        case 0x01:
             let currentcnt = CommonUtils.byte2Day(data: CommonUtils.copyofRange(data: revdata, from: 5, to: 8))
            if !issendding && isContinue{
                self.sendbaonum = 1
                issendding = true
                sendotherbao(num: 1)
            }
             self.UpdateProgressView.progress = Float(currentcnt)/Float(downdata.count/sendbaocount)
             let pregressnum = sendbaocount*100*Int(currentcnt)/downdata.count
             self.updateinderlabel.text = "\(pregressnum)%"
            print("目前接受到的包\(currentcnt)")
             if currentcnt >= downdata.count/sendbaocount && sendtimer == nil{
                sendtimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sendlastbao), userInfo: nil, repeats: true)
            }
            
        case 0x81:
            
            let errorcnt = CommonUtils.byte2Day(data: CommonUtils.copyofRange(data: revdata, from: 5, to: 8))
            self.sendbaonum = Int(errorcnt)
             sendotherbao(num: sendbaonum)
             print("目前接受到的包\(errorcnt)")
            
            
        case 0x0F:
            
            if sendtimer != nil{
                sendtimer.invalidate()
                sendtimer = nil
            }
            BleTools.SOFTVERSION = self.firmwareVersion
            self.UpdateLabel.text = "升级成功"
             isupdate = false
             isupdating = false
            isstartupdate = false
            issendding = false
            initview()
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.SendStateCmd, data:[WATCHSTATUS.STATUS_OK.rawValue])))
            if addtimer != nil{
                addtimer.invalidate()
                addtimer = nil
                ToastView.instance.showToast(content: "手表升级成功")
            }
           
        default:
            break
        }
    }
    
    //通知发送包
    func sendbao(){
        if issendding{
            sendbaonum += 1
             self.sendotherbao(num: sendbaonum)
            var endpos = (sendbaonum) * sendbaocount
                if endpos >= downdata.count{
                    issendding = false
                    isContinue = false
                   
            }
            
            
        }
    }
    //发送第n包的数据 包括cnt+文件内容
    func sendotherbao(num : Int ){
        let data1 = Data.init(bytes: CommonUtils.int2data(num: num))
        let startpos = (num-1) * sendbaocount
        var endpos = (num) * sendbaocount
        if endpos >= downdata.count{
            endpos = downdata.count
        }
        if startpos < endpos{
            let data2 = Data.init(bytes: CommonUtils.copyofRange(data: [UInt8](downdata), from: startpos, to: endpos-1))
            var senddata : Data = Data()
            senddata.append(data1)
            senddata.append(data2)
            print([UInt8](senddata))
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.MCUCmd1, data: [UInt8](senddata))) )
        }else{
            issendding = false
            sendbaonum -= 1
        }
    }
    //发送头包的数据 包括cnt+数据长度+文件名称
    func sendfirstbao(){
        let data1 = Data.init(bytes: CommonUtils.int2data(num: 0))
        let data2 = Data.init(bytes: CommonUtils.int2data(num: downdata.count))
        let filename = self.firmwareVersion+".bin"
        let data3  = filename.data(using: String.Encoding.utf8)
        var senddata : Data = Data()
        senddata.append(data1)
        senddata.append(data2)
        senddata.append(data3!)
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.MCUCmd1, data: [UInt8](senddata))) )
    }
    func sendlastbao(){
        let senddata = Data.init(bytes: CommonUtils.int2data(num: sendbaonum+1))
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.MCUCmd1, data: [UInt8](senddata))) )
        isstartupdate = false
    }
    
    //检测是否超时
    func addtime(){
        let nowTime = Date().timeIntervalSince1970
        let waittime  = nowTime - self.revTime
        if waittime >= 5{
            issendding = false
            isstartupdate = false
            isupdating = false
            //timer.invalidate()
            addtimer.invalidate()
            timer = nil
            addtimer = nil
            initview()
            ToastView.instance.showAlert("数据发送超时,升级失败", self)
           
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
