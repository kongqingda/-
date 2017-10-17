//
//  BindDeviceViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import CoreBluetooth

class BindDeviceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var bindstateimage: UIImageView!
    @IBOutlet weak var BindNameLabel: UILabel!
    @IBOutlet weak var BindDeviceBtn: UIButton!
    @IBOutlet weak var BindDateLabel: UILabel!
    @IBOutlet weak var BleTableView: UITableView!
    @IBOutlet weak var ReloadIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var ReloadBtn: UIButton!
    @IBOutlet weak var BleStateLabel: UILabel!
    @IBOutlet weak var BindIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var BindView: UIView!
    let main = MainController()
    var selectrow : Int!
    var alert , WaitAlert :UIAlertController!
    var timer : Timer!
    var isbinding : Bool = false
    var connstate : blestate = blestate.ble_disconn
    var bindperipheral : CBPeripheral!
    private var dateFormatter = DateFormatter()
    
    var tabledata : Array = [DeviceData]()
    
    var selectper : CBPeripheral!
    var iswaitbind : Bool = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
       // self.tabBarController?.tabBar.selectedImageTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.BleTableView.delegate = self
        self.BleTableView.dataSource = self
        
        initNotification()
        
        ReloadIndicatorView.stopAnimating()
        BindIndicatorView.stopAnimating()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        BindView.isHidden = true
        let userdefaults : UserDefaults = .standard
        let bindper = userdefaults.string(forKey: "bindper")
        if bindper != nil {
            changeView()
        }
        // Do any additional setup after loading the view.
    }
    
    func initNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(ShowbindView), name: Notification.Name("bleconn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.savebindpermsg(_notification:)), name: Notification.Name("STATUS"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.reloadlist(_:)), name: Notification.Name("reloadlist"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadlist(_ notification : Notification){
        tabledata = BleTools.deviceArray
        BleTableView.reloadData()   
    }
    
    @IBAction func ReloadBtnAction(_ sender: Any) {
        if ReloadBtn.titleLabel?.text == "刷新" {
            ReloadIndicatorView.startAnimating()
            if(BleStateLabel.text == "正在扫描设备..."){
                return
            }else{

                BleTools.sharedInstance.scanDevice()
                ReloadIndicatorView.startAnimating()
                BleTableView.isScrollEnabled = false
                BleTableView.allowsSelection = false
                timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(myTimer), userInfo: nil, repeats: false)
                BleStateLabel.text = "正在扫描设备..."
            }
            return

        }
        if ReloadBtn.titleLabel?.text == "解除绑定"{
             bindstateimage.image = UIImage.init(named: "蓝牙连接.png")
            let userdefaults : UserDefaults = .standard
            userdefaults.set(nil,forKey: "bindper")
            userdefaults.set(nil, forKey: "binddate")
            userdefaults.set(nil, forKey: "bindname")
            MainController.BINDPER = nil
            userdefaults.synchronize()
            if BleTools.BTState == blestate.ble_conn {
                if BleTools.bindperipheral != nil{
                    BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
                }
                
            }
            NotificationCenter.default.post(name: NSNotification.Name("bindcancel"), object: nil, userInfo: nil)
            self.BindNameLabel.text = "设备名称：无"
            self.BindDateLabel.text = "绑定时间：无"
            //changeView()
            return

        }
    }
    
    func myTimer() {
        tabledata = BleTools.deviceArray
        tabledata.sort { (device1, device2) -> Bool in
            if device1.rssi.intValue > device2.rssi.intValue{
                return true
            }else{
                return false
            }
        }
        BleTableView.reloadData()
        BleTableView.isScrollEnabled = true
        BleTableView.allowsSelection = true
        if tabledata.count != 0{
            BleStateLabel.text = "请选择以下设备绑定"
        }else{
            BleStateLabel.text = "点击刷新扫描设备"
        }
        ReloadIndicatorView.stopAnimating()
        BleTools.sharedInstance.stopScanDevice()
        timer.invalidate()
        timer = nil;
    }

    
    //连接超时关闭waitalert
    func outTimeCloseAlert() {
        if BindIndicatorView.isAnimating{
            ToastView.instance.showToast(content: "连接超时")
            BindIndicatorView.stopAnimating()
            BindDeviceBtn.isHidden = false
        }
    }
    
    //设备连接以后弹出配对view
    func ShowbindView(_notification : Notification ) {

        connstate = BleTools.BTState
        BindIndicatorView.stopAnimating()
        BindDeviceBtn.isHidden = false
        
    switch BleTools.BTState {
        case blestate.ble_conn:
            if self.BindView.isHidden{
                switch BleTools.bindperipheral?.name{
                case "TH802"?:
                    sendpercmd()
                case "TH902"?:
                    savebinddevice()
                default:
                     break
                }
            }
        case blestate.ble_connfail:
            alert = UIAlertController(title:"蓝牙配对",message:"手表匹配失败，请重新配对！",preferredStyle: .alert)
            let OKAction = UIAlertAction(title:"确定",style:.default){
                (alertAction) -> Void in
                self.alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(OKAction)
            self.present(alert,animated:true,completion: nil)
        case blestate.ble_disconn:
            alert = UIAlertController(title:"蓝牙配对",message:"手表断开连接！",preferredStyle: .alert)
            let OKAction = UIAlertAction(title:"确定",style:.default){
                (alertAction) -> Void in
                self.alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(OKAction)
            self.present(alert,animated:true,completion: nil)
            
        default: break
            
        }
        
    }
    //TH802发送匹配指令
    func sendpercmd(){
        //发送匹配指令
        let pairnum : Int = createRandom()
        let q : Int = 256
        var alldata : Array<UInt8>!
        let bleorders  = BleOrders()
        let data : Array<UInt8> = [UInt8(pairnum % q),UInt8((Double(pairnum / q)))]
        alldata = bleorders.myorder(cmd: SENDCMD.PairCmd, data: data)
        print(pairnum)
        var senddata : Data = Data.init(bytes: alldata)
        print(senddata.description)
        BleTools.sharedInstance.APPsendData(data: senddata)
        
        //蓝牙配对指令
        alert = UIAlertController(title:"蓝牙配对",message:"",preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (textField : UITextField) in
            textField.placeholder = "请输入配对码"
            textField.keyboardType = .numberPad
            textField.textAlignment = .center
        })
        let OKAction = UIAlertAction(title:"配对",style:.default){
            (alertAction) -> Void in
            print(String(pairnum))
            print(self.alert.textFields?[0].text)
            
            //判断是否匹配成功,
            //self.alert.textFields?[0].text  == String(pairnum)
            if self.alert.textFields?[0].text  == String(pairnum){
                //发送匹配成功指令
                if BleTools.BTState == blestate.ble_conn{
                    print("发送配对指令成功")
                    alldata = bleorders.myorder(cmd: SENDCMD.OKPairCmd, data: nil)
                    senddata = Data.init(bytes: alldata)
                    usleep(500)
                    BleTools.sharedInstance.APPsendData(data: senddata)
                    self.isbinding = true
                    
                }else{
                    self.isbinding = false
                    self.alert = UIAlertController(title:"蓝牙配对",message:"手表断开连接！",preferredStyle: .alert)
                    let OKAction = UIAlertAction(title:"确定",style:.default){
                        (alertAction) -> Void in
                        self.alert.dismiss(animated: true, completion: nil)
                    }
                    self.alert.addAction(OKAction)
                    self.present(self.alert,animated:true,completion: nil)
                }
                
            }else{
                self.isbinding = false
                self.alert = UIAlertController(title:"蓝牙配对",message:"蓝牙配对失败！",preferredStyle: .alert)
                let OKAction = UIAlertAction(title:"配对",style:.default){
                    (alertAction) -> Void in
                    BleTools.sharedInstance.disConnectDevice(per:BleTools.bindperipheral!)
                    self.alert.dismiss(animated: true, completion: nil)
                }
                self.alert.addAction(OKAction)
                self.present(self.alert,animated:true,completion: nil)
            }
            
        }
        alert.addAction(OKAction)
        self.present(alert,animated:true,completion: nil)
    }
    
    // 判断手表发送的状态实现对绑定设备的存储
    func savebindpermsg(_notification : Notification) {
        if isbinding && iswaitbind{
            let status = _notification.object as! WATCHSTATUS
            if status == WATCHSTATUS.STATUS_OK{
                savebinddevice()
                // NotificationCenter.default.post(name: Notification.Name("bindsuccess"), object: nil, userInfo: nil)
            }

        }
    }
    
    func savebinddevice()  {
        let userdefaults : UserDefaults = .standard
        userdefaults.set(selectper.identifier.uuidString ,forKey: "bindper")
        userdefaults.set(selectper.name ,forKey: "bindname")
        let date : String = dateFormatter.string(from: Date())
        userdefaults.set(date, forKey: "binddate")
        userdefaults.synchronize()
        changeView()
        MainController.BINDPER = selectper.identifier.uuidString
        iswaitbind = false
    }
    
    //改变视图
    func changeView() {
        if(!self.BleTableView.isHidden){
            self.BleTableView.isHidden = true
            let userdefaults : UserDefaults = .standard
            let bindname = userdefaults.string(forKey: "bindname")
            let binddate = userdefaults.string(forKey: "binddate")
            self.BindView.isHidden = false
            self.BindNameLabel.text = "设备名称："+bindname!
            self.BindDateLabel.text = "绑定时间："+binddate!
            ReloadBtn.setTitle("解除绑定", for: .normal)
            BindDeviceBtn.setTitle("绑定新设备", for: .normal)
            BleStateLabel.text = "已绑定设备"
            bindstateimage.image = UIImage.init(named: "绑定图标.png")
             self.isbinding = false
        }else{
            bindstateimage.image = UIImage.init(named: "蓝牙连接.png")
            self.BleTableView.isHidden = false
            self.BindView.isHidden = true
            BleStateLabel.text = "点击刷新扫描设备"
            ReloadBtn.setTitle("刷新", for: .normal)
            BindDeviceBtn.setTitle("绑定", for: .normal)
            //self.BleTableView.reloadData()
        }
      
    }
    
    
    
    
    //生成4位随机数
    //随机数生成器函数
    func createRandom() ->Int {
        let max: UInt32 = 9999 //最大数
        let min: UInt32 = 1000 //最小数
        return Int(arc4random_uniform(max - min) + min)
        
    }
    
    //连接设备

    @IBAction func BindDeviceBtnAction(_ sender: Any) {
        if BindDeviceBtn.titleLabel?.text == "绑定"{
            if selectrow != nil{
                iswaitbind = true
                BindIndicatorView.startAnimating()
                BindDeviceBtn.isHidden = true
                BleTools.sharedInstance.connectDevice(per: tabledata[(BleTableView.indexPathForSelectedRow?.row)!].peripheral)
                timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(outTimeCloseAlert), userInfo: nil, repeats: false)

            }else {
                alert = UIAlertController(title:"警告！",message:"请先选择连接设备",preferredStyle: .alert)
                let OKAction = UIAlertAction(title:"确定",style:.default){
                    (alertAction) -> Void in
                    self.alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(OKAction)
                self.present(alert,animated:true,completion: nil)
            }
            return

        }
        if BindDeviceBtn.titleLabel?.text == "绑定新设备"{
            changeView()
            return
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
    //刷新RSSI
    func reloadrssi(){
        tabledata = BleTools.deviceArray
        BleTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tabledata.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DeviceCell = BleTableView.dequeueReusableCell(withIdentifier: "devicecell", for: indexPath as IndexPath) as! DeviceCell
        if self.tabledata.count > 0
        {
            let device = self.tabledata[indexPath.row] as DeviceData
            if device.peripheral.name != nil {
                if device.peripheral.name == "TH802"{
                    cell.deviceicon?.image = UIImage(named:"手表图标.png")
                }
                if device.peripheral.name == "TH902"{
                    cell.deviceicon?.image = UIImage(named:"胸贴图标.png")
                }
                
                cell.selectimage.image = UIImage(named: "未选中.png")
                //cell.devicerssi?.text = String(describing: device.rssi)
                cell.devicename.text = (device.peripheral.name)!
                //device.readRSSI()
                cell.devicerssi?.text = String.init(format: "RSSI:%d", device.rssi.intValue )

                //pow(Double(10), (abs(device.rssi! as! double) - 59) / (10 * 2.0)))
                print((device.description))
                beforeindex = nil
                
            }
        }
        
        return cell;
    }
    
    var beforeindex : IndexPath? = nil
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectrow = indexPath.row
        print(selectrow)
//        if beforeindex != nil {
//            let beforecell : DeviceCell = tableView.cellForRow(at: beforeindex!) as! DeviceCell
//            beforecell.selectimage.image = UIImage(named: "未选中.png")
//        }
        //let selectcell : DeviceCell = tableView.cellForRow(at: indexPath) as! DeviceCell
        //selectcell.selectimage.image = UIImage(named: "已选中.png")
        beforeindex = indexPath
        selectper = self.tabledata[selectrow].peripheral
    }
    
    
    func calcDistByRSSI(rssi:NSNumber) -> Double
    {
        if rssi != nil{
            let iRssi : Int  = -(rssi.intValue);
            let power = Double(iRssi-59)/(10*2.0);
            let result : Double = pow(10, power)
            return result
            
        }else{
            return 100
        }
        
    }
}
