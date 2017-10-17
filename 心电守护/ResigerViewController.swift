//
//  ResigerViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Alamofire

class ResigerViewController: UIViewController {

    @IBOutlet weak var GetBtn: UIButton!
    @IBOutlet weak var RegisterBtn: UIButton!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBOutlet weak var AutoCodeTextField: UITextField!
    @IBOutlet weak var PassWordTextField: UITextField!
    @IBOutlet weak var ConPassWordTextField: UITextField!
    
    var timer : Timer!
    
    var netutil : netUtil!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(requestVerifyCode(notification:)), name: Notification.Name("requestVerifyCode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resiger(notification:)), name: Notification.Name("resiger"), object: nil)
        netutil = netUtil.sharedInstance
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GetBtnAction(_ sender: Any) {
        if PhoneTextField.text?.characters.count == 11{
            netutil.requestVerifyCode(phone: PhoneTextField.text!, type: "1")

        }else{
            print("请输入正确的手机号")
            ToastView.instance.showToast(content: "请输入11位长度手机号码")
        }
        
    }
    @IBAction func RegisterBtnAction(_ sender: Any) {
        let phone = PhoneTextField.text
        let code = AutoCodeTextField.text
        let pwd = PassWordTextField.text
        let conpwd = ConPassWordTextField.text
        if phone?.characters.count == 11 {
            if code?.characters.count == 6{
                if (pwd?.characters.count)! >= 6 && (conpwd?.characters.count)! >= 6 {
                    if pwd == conpwd {
                        ToastView.instance.showLoadingView(content: "请等待...")
                        netutil.resiger(code: code!, pwd: pwd!, phone: phone!)
                    }else{
                        ToastView.instance.showToast(content: "两次输入的密码不一致")
                    }
                }else{
                    ToastView.instance.showToast(content: "请按要求填写密码")
                }
            }else{
                ToastView.instance.showToast(content: "请4位长度输入验证码")
            }
        }else{
            ToastView.instance.showToast(content: "请输入11位长度手机号码")
        }
        
    }
    //获取验证码的通知
    func requestVerifyCode(notification:Notification) {
        let json:NSDictionary =  notification.object as! NSDictionary
        ToastView.instance.clear()
        let result = json["result"] as! Int
        if result == 0{
            ToastView.instance.showToast(content: "已获取到验证码，请查看手机")
            if timer != nil {
                timer.invalidate()
                timer = nil
            }
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(mytimer), userInfo: nil, repeats: true)
            
        }else{
            
            ToastView.instance.showToast(content: json["remark"] as! String)
            
        }
        
    }
    
    //获取注册的通知
    func resiger(notification:Notification)  {
        let json:NSDictionary =  notification.object as! NSDictionary
         ToastView.instance.clear()
        let result = json["result"] as! Int
        if result == 0{
            ToastView.instance.showToast(content: "注册成功")
            let userdefault : UserDefaults = .standard
            userdefault.set(PhoneTextField.text, forKey: "phone")
            userdefault.set(PassWordTextField.text, forKey: "pwd")
            userdefault.synchronize()
            self.dismiss(animated: true, completion: nil)
            
            
        }else{
            
            ToastView.instance.showToast(content: json["remark"] as! String)
            
        }
       

    }
    
    //验证时间变化
    var num : Int = 60
    func mytimer(){
        if num != 0{
            GetBtn.isEnabled = false
            GetBtn.setTitle("\(num)s", for: .normal)
            num -= 1
        }else{
            GetBtn.isEnabled = true
            GetBtn.setTitle("获取验证码", for: .normal)
            timer.invalidate()
            timer = nil
            num = 60
        }
    }
    
    @IBAction func dimissaction(_ sender: Any) {
        self.dismiss(animated: true) {
            if self.timer  != nil{
                self.timer.invalidate()
                self.timer = nil
            }
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
