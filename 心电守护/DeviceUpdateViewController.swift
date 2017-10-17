//
//  DeviceUpdateViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
// 固件升级

import UIKit

class DeviceUpdateViewController: UIViewController {

    @IBOutlet weak var databaoimage: UIImageView!
    @IBOutlet weak var updateimage: UIImageView!
    @IBOutlet weak var UpdateView: UIView!
    @IBOutlet weak var UpdateLabel: UILabel!
    @IBOutlet weak var UpdateProgressView: UIProgressView!
    @IBOutlet weak var UpdateBtn: UIButton!
    @IBOutlet weak var updateview: UIView!
    
    var isupdate : Bool = true //检查是否需要升级
    var isupdating : Bool = false //正在升级中
    var currentSR : String = "当前手表固件版本为1.0" //当前手表固件版本
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Do any additional setup after loading the view.
        initdata()
        initview()
    }
    func initdata(){
        var type : String = "1"
        if AppDelegate.netstyle != .notReachable{
            if BleTools.bindperipheral != nil{
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
    func initview() {
        currentSR = "当前手表固件版本:\(BleTools.SOFTVERSION)"
         databaoimage.isHidden = true
        if isupdate{
            UpdateBtn.isHidden = false
            self.UpdateLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            if isupdating{
                self.updateview.isHidden = false
                self.updateimage.isHidden = false
                self.UpdateLabel.text = "正在升级中..."
                databaoimage.layer.add(AnimationUtil.getImagedataAnimation(), forKey: "animation")
                databaoimage.isHidden = false
            }else{
                self.updateview.isHidden = false
                self.updateimage.isHidden = false
                self.UpdateLabel.text = "固件版本需要更新,点击升级"
            }
           
        }else{
             UpdateBtn.isHidden = true
            self.updateview.isHidden = true
            self.updateimage.isHidden = true
            self.UpdateLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.UpdateLabel.text = currentSR
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func UpdateBtnAction(_ sender: Any) {
        isupdating = true
        initview()
    }
    @IBAction func closeaction(_ sender: Any) {
        self.dismiss(animated: true) {
            
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
