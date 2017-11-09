//
//  OtherSetViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class OtherSetViewController: UITableViewController {

    @IBOutlet weak var isright: UISwitch!
    @IBOutlet weak var ismobilenet: UISwitch!
    @IBOutlet weak var isdebug: UISwitch!
    let userdefaults : UserDefaults = .standard
    override func viewDidLoad() {
        super.viewDidLoad()
        let myhand = userdefaults.integer(forKey: "myhand")
        let debug = userdefaults.bool(forKey: "isdebug")
        if myhand == hand.righthand.rawValue{
            isright.isOn = false
        }else{
            isright.isOn = true
        }
        if debug{
             isdebug.isOn = true
        }else{
             isdebug.isOn = false
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    @IBAction func isrightaction(_ sender: UISwitch) {
        
        if sender.isOn{
            userdefaults.set(1, forKey: "myhand")
            DrawLineView.myhand = hand.lefthand
            }else{
            userdefaults.set(0, forKey: "myhand")
            DrawLineView.myhand = hand.righthand
            
        }
        userdefaults.synchronize()

        
    }
    @IBAction func ismobilenetaction(_ sender: UISwitch) {
    }
    
    @IBAction func isdebugaction(_ sender: UISwitch) {
        if sender.isOn{
            userdefaults.set(true, forKey: "isdebug")
        }else{
            userdefaults.set(false, forKey: "isdebug")
            
        }
        NotificationCenter.default.post(name: Notification.Name("isdebug"), object: sender.isOn)
        userdefaults.synchronize()
    }
    @IBAction func quitaction(_ sender: Any) {
        if BleTools.bindperipheral != nil{
            BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
        }
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("closeapp"), object: nil)
            self.userdefaults.set(nil, forKey: "pwd")
            self.userdefaults.set(nil, forKey: "phone")
            self.userdefaults.set(nil, forKey: "bindmac")
            self.userdefaults.set(nil, forKey: "bindper")
            self.userdefaults.set(nil, forKey: "binddate")
            self.userdefaults.set(nil, forKey: "bindname")
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
