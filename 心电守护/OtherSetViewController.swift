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
        if myhand == hand.righthand.rawValue{
            isright.isOn = false
        }else{
            isright.isOn = true
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
    }
    @IBAction func quitaction(_ sender: Any) {
        if BleTools.bindperipheral != nil{
            BleTools.sharedInstance.disConnectDevice(per: BleTools.bindperipheral!)
        }
        self.dismiss(animated: true, completion: nil)
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
