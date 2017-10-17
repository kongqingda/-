//
//  MainController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/21.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
enum batterynum : Int {
    case batteryone = 0
    case batterytwo = 1
    case batterythree = 2
    case batteryfour = 3
    case batterycharge = 4
}
class MainController: UITabBarController {
    static var ThemeColor : UIColor =  #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)  //主题颜色
    static var isSendable : Bool = true //是否允许发送命令
    
    let bleorders : BleOrders = BleOrders()
    let toastview : ToastView = ToastView.instance
    static var softVer : String = ""
    var batterymsg : UInt8 = 0x80
    var timer : Timer!
    static var BINDPER : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        print("启动程序")
        BleDataAnalysis.shareInstance
        let userdefaults : UserDefaults = .standard
        MainController.BINDPER = userdefaults.string(forKey: "bindper")
       // NotificationCenter.default.addObserver(self, selector: #selector(revdata(_:)), name: Notification.Name("REVDATA"), object: nil)
        if userdefaults.integer(forKey: "myhand")  == nil {
            userdefaults.set(0, forKey: "myhand")
            DrawLineView.myhand = hand.righthand
        }
        NotificationCenter.default.addObserver(self, selector: #selector(getblestate), name: Notification.Name("bleconn"), object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    
    var iswait : Bool = false
    func getblestate() {
        if BleTools.BTState == .ble_conn{
            let date : Date  = Date()
            let calendar : Calendar = Calendar.current
            let currentyear = calendar.component(.year, from: date) - 2000
            let currentmonth = calendar.component(.month, from: date)
            let currentday = calendar.component(.day, from: date)
            var currentweek = calendar.component(.weekday, from: date) - 2
            if currentweek == -1{
                currentweek = 6
            }
            let currenthour = calendar.component(.hour, from: date)
            let currentminute = calendar.component(.minute, from: date)
            let currentsecond = calendar.component(.second, from: date)
            let currentmsecond = Double(calendar.component(.nanosecond, from: date) / 1000000)
            var data : Array<UInt8> = []
            data.append(UInt8(Int(currentmsecond) % 256))
            data.append(UInt8(currentmsecond / 256))
            data.append(UInt8(currentsecond))
            data.append(UInt8(currentminute))
            data.append(UInt8(currenthour))
            data.append(UInt8(currentweek))
            data.append(UInt8(currentday))
            data.append(UInt8(currentmonth))
            data.append(UInt8(currentyear % 256))
            data.append(UInt8(Double(currentyear / 256)))
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.SetTimeCmd, data: data)) )
            print("调时成功")
        }
    }
    //定期执行的操作
    func sendcmd(){
        if BleTools.BTState == .ble_conn{
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.WatchBatteryCmd, data: nil)) )
        }else{
            let batterymsg = 5
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "batterymsg"), object: batterymsg)
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
