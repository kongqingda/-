//
//  WatchTimeController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/10/11.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class WatchTimeController: UIViewController {

    @IBOutlet weak var timeprogress: UIImageView!
    @IBOutlet weak var textimage: UIImageView!
    @IBOutlet weak var refresh: UIButton!
    @IBOutlet weak var undobtn: UIButton!
    
    @IBOutlet weak var imageviewwidth: NSLayoutConstraint!
    @IBOutlet weak var leftbtn: UIBarButtonItem!
    @IBOutlet weak var rightbtn: UIBarButtonItem!
    @IBOutlet weak var WatchimageView: UIImageView!
    var operatorstep : Int = 0
    let bleorders : BleOrders = BleOrders()
    var waitimer : Timer!
    var isback12msg : Bool = false
    var isadjusttimemsg : Bool = false
    var cmdThread : Thread = Thread()
    override func viewDidLoad() {
        super.viewDidLoad()
        initview()
        // Do any additional setup after loading the view.
    }
    
    func initview() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        undobtn.isHidden = true
        refresh.isHidden = true
        timeprogress.isHidden = true
        leftbtn.isEnabled = false
        rightbtn.isEnabled = false
        if MainController.BINDPER == nil{
            ToastView.instance.showAlert("请先对手表进行配对",self)
        }
        if BleTools.BTState == .ble_conn{
            NotificationCenter.default.addObserver(self, selector: #selector(back12msg), name: Notification.Name("back12msg"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(adjusttimemsg(_:)), name: Notification.Name("adjusttimemsg"), object: nil)
            cmdThread = Thread.init(target: self, selector: #selector(resendcmd), object: nil)
            cmdThread.start()
        }else{
             ToastView.instance.showAlert("请检查蓝牙连接",self)
        }
        
      
    }
    

    //归12点
    func back12msg() {
        isback12msg = true
        if waitimer != nil{
            waitimer.invalidate()
            waitimer = nil
        }
        waitimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(showbtnenble), userInfo: nil, repeats: false)
    }
    //检查指令是否回复成功，否则重复发送
    func resendcmd(){
        switch operatorstep {
        case 0:
            while !isback12msg{
                BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.Test12Cmd, data: nil)) )
                sleep(2)
            }
         case 1:
            while !isadjusttimemsg{
                BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd, data: [0x00])) )
                sleep(2)
            }
        default:
            break
        }
        
        
      
    }
    //显示左右控件
    func showbtnenble() {
        leftbtn.isEnabled = true
        rightbtn.isEnabled = true
    }
    
    //调节时间
    func adjusttimemsg(_ notification : Notification) {
        isadjusttimemsg = true
        var data  = notification.object as! [UInt8]
        switch  data[4] {
        case 1:
            timeprogress.image = UIImage.init(named: "调针进度2.png")
        case 5:
            timeprogress.image = UIImage.init(named: "调针进度3.png")
        case 6:
            timeprogress.image = UIImage.init(named: "调针进度4.png")
         
        case 7:
            timeprogress.image = UIImage.init(named: "调针进度5.png")
           
        case 0x87:
            textimage.image = UIImage.init(named: "归到12点.png")
            timeprogress.image = UIImage.init(named: "调针进度6.png")
           showbtnenble()
            
        default:
            break
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeaction(_ sender: Any) {
        isback12msg  = true
        isadjusttimemsg = true
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd, data: [0x01])) )
        self.dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func leftbtnaction(_ sender: Any) {
        print("是")
        closeaction((Any).self)
    }
    
    @IBAction func rightbtnaction(_ sender: Any) {
        operatorstep += 1
        switch operatorstep {
        case 1:
            self.view.layer.removeAllAnimations()
            WatchimageView.layer.add(AnimationUtil.getImageChangeAnimation(), forKey: "animation")
            cmdThread = Thread.init(target: self, selector: #selector(resendcmd), object: nil)
            cmdThread.start()
            textimage.image = UIImage.init(named: "正在调针.png")
            timeprogress.isHidden = false
            rightbtn.isEnabled = false
            leftbtn.isEnabled = false
        case 2:
           self.view.layer.removeAllAnimations()
           WatchimageView.layer.add(AnimationUtil.getImageChangeAnimation(), forKey: "animation")
            timeprogress.isHidden = true
             textimage.image = UIImage.init(named: "移动时针.png")
            WatchimageView.image = UIImage.init(named: "北斗-时针.png")
             undobtn.isHidden = false
             refresh.isHidden = false
            leftbtn.isEnabled = false
            rightbtn.title = "下一步"
        case 3:
            WatchimageView.layer.add(AnimationUtil.getImageChangeAnimation(), forKey: "animation")
             textimage.image = UIImage.init(named: "移动分针.png")
             WatchimageView.image = UIImage.init(named: "北斗-拷贝-分针.png")
            leftbtn.isEnabled = false
        case 4:
            WatchimageView.layer.add(AnimationUtil.getImageChangeAnimation(), forKey: "animation")
            textimage.image = UIImage.init(named: "移动秒针.png")
             WatchimageView.image = UIImage.init(named: "北斗-秒针.png")
            leftbtn.isEnabled = false
        case 5:
            //WatchimageView.layer.add(AnimationUtil.getImageChangeAnimation(), forKey: "animation")
            undobtn.isHidden = true
            refresh.isHidden = true
            leftbtn.isEnabled = false
            rightbtn.isEnabled = true
            rightbtn.title = "确定"
            textimage.image = UIImage.init(named: "时间匹配.png")
            imageviewwidth.constant = 190
            WatchimageView.image = UIImage.init(named: "图层-5.png")
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd, data: [0x01])) )
        case 6:
            closeaction((Any).self)
        default:
            break
        }
        
       
    }
    @IBAction func undoaction(_ sender: Any) {
          print("左转")
        switch  operatorstep {
        case 2:
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd_hh, data: CommonUtils.int2data(num: -1))) )
        case 3:
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd_mm, data: CommonUtils.int2data(num: -1))) )
        case 4:
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd_ss, data: CommonUtils.int2data(num: -1))) )
        default:
            break
        }
        
    }
    @IBAction func refreshaction(_ sender: Any) {
          print("右转")
        switch  operatorstep {
        case 2:
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd_hh, data: CommonUtils.int2data(num: 1))) )
        case 3:
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd_mm, data: CommonUtils.int2data(num: 1))) )
        case 4:
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.AdjustTimeCmd_ss, data: CommonUtils.int2data(num: 1))) )
        default:
            break
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
