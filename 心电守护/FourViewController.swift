//
//  FourViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class FourViewController: UITableViewController {
    static var updateecgdata : Int32 = 0
    @IBOutlet weak var watchupdate: UIImageView!
    @IBOutlet weak var dataupdate: UIImageView!
    let bleorders : BleOrders = BleOrders()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(getallmsg(_:)), name: Notification.Name("getallmsg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hinddataupdate), name: Notification.Name("isclearupdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeAction), name: Notification.Name("closeapp"), object: nil)
        watchupdate.isHidden = true
        dataupdate.isHidden = true
        if BleTools.BTState == .ble_conn{
             senddata()
        }else{
            NotificationCenter.default.addObserver(self, selector: #selector(senddata), name: Notification.Name("bleconn"), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func hinddataupdate(){
        self.dataupdate.isHidden = true
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 30
        }
        return 10
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func closeAction(){
        removeNotification()
        self.dismiss(animated: true, completion: nil)
    }
    func senddata(){
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: bleorders.myorder(cmd: SENDCMD.GetAllMessageCmd, data: nil)) )
    }
    func getallmsg(_ notification : Notification){
        var alldata : [UInt8] = notification.object as! [UInt8]
        alldata.removeLast()
        alldata.removeSubrange(0..<4)
        FourViewController.updateecgdata = CommonUtils.byte2Day(data: CommonUtils.copyofRange(data: alldata, from: 12, to: 15))
        if FourViewController.updateecgdata > 0{
            dataupdate.isHidden = false
        }
    }
    
    func removeNotification(){
       NotificationCenter.default.removeObserver(self)
    }

}
