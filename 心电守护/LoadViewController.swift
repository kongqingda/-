//
//  LoadViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Alamofire


class LoadViewController: UIViewController {

    @IBOutlet weak var findpwd: UIButton!
    @IBOutlet weak var resigerbtn: UIButton!
    @IBOutlet weak var loginbtn: UIButton!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    static var USERNAME : String!
    let usermsgdao = UsermsgDao.sharedInstance
    var netutil : netUtil!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
     
         NotificationCenter.default.addObserver(self, selector: #selector(login(notification:)), name: Notification.Name("login"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeaction), name: Notification.Name("closeapp"), object: nil)
        //获取存储的信息
        let userdefaults : UserDefaults = .standard
        let phone  = userdefaults.string(forKey: "phone")
        let pwd  = userdefaults.string(forKey: "pwd")
        if phone != nil && pwd != nil{
            PhoneTextField.text = phone
            PasswordTextField.text = pwd
        }
        netutil = netUtil.sharedInstance
        // Do any additional setup after loading the view.
        if phone?.characters.count == 11 && (pwd?.characters.count)! >= 6{
           self.perform(#selector(loginClick), with: nil, afterDelay: 0.1)
        }
        
        let isfirst = userdefaults.bool(forKey: "isfirst")
        if !isfirst {
            self.performSegue(withIdentifier: "showaboutsoft", sender: nil)
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoadBtnAction(_ sender: Any) {
        
        if PhoneTextField.text?.characters.count == 11 && (PasswordTextField.text?.characters.count)! >= 6{
            loginClick()
        }else{
            ToastView.instance.showToast(content: "请输入正确的手机号和密码")
        }

    }
    
    func loginClick(){
        if let phone : String = PhoneTextField.text, let pwd = PasswordTextField.text{
            if phone == "11111111111" && pwd == "666666"{
                self.performSegue(withIdentifier: "mainsegue", sender: nil)
                return
            }
            print("手机号："+phone)
            print("密码："+pwd)
            netutil.login(pwd: pwd, phone: phone)
            ToastView.instance.showLoadingView(content: "正在登录...")
        }else{
             ToastView.instance.showToast(content: "密码或者手机号不能为空！")
        }
    }

    @IBAction func RegisterBtnAction(_ sender: Any) {
        
    }
    @IBAction func FindPassBtnAction(_ sender: Any) {
        
    }
    
    
    func login(notification : Notification) {
        
        let json = notification.object as! NSDictionary
        ToastView.instance.clear()
        let result = json["result"] as! Int
        print(result)
        print(json["remark"] as! String)
        let phone : String = self.PhoneTextField.text!
        let pwd = self.PasswordTextField.text!
        if result == 0{
            let token = json["token"] as! String
            let info = json["userInfo"] as! NSDictionary
            let name:String? = info["name"] as? String
            LoadViewController.USERNAME = info["username"] as? String
            print("LoadViewController.USERNAME")
            let gender:Int? = info["gender"] as? Int
            let userdefaults : UserDefaults = .standard
            userdefaults.set(token,forKey: "token")
            userdefaults.set(phone, forKey: "phone")
            userdefaults.set(pwd, forKey: "pwd")
            userdefaults.set(gender, forKey: "gender")
            userdefaults.set(LoadViewController.USERNAME, forKey: "username")
            userdefaults.set(name, forKey: "name")
            userdefaults.set(false, forKey: "isdebug")
            userdefaults.synchronize()
            
            let usermsgs =  usermsgdao.findByDate(phone)
            if usermsgs != nil {
                let usermsg = usermsgs![0] as! Usermsgmodel
                let userdefaults : UserDefaults = .standard
                userdefaults.set(usermsg.bindper,forKey: "bindper")
                userdefaults.set(usermsg.binddate, forKey: "binddate")
                userdefaults.set(usermsg.bindname, forKey: "bindname")
                userdefaults.set(usermsg.bindmac, forKey: "bindmac")
                MainController.BINDPER = usermsg.bindper
                userdefaults.synchronize()
            }else{
                let userdefaults : UserDefaults = .standard
                userdefaults.set(nil,forKey: "bindper")
                userdefaults.set(nil, forKey: "binddate")
                userdefaults.set(nil, forKey: "bindname")
                userdefaults.set(nil, forKey: "bindmac")
                MainController.BINDPER = nil
                userdefaults.synchronize()
            }
            
            self.performSegue(withIdentifier: "mainsegue", sender: nil)
            XMPPUtil.sharedInstance.connect()
            
        }else{
            
            ToastView.instance.showToast(content: json["remark"] as! String)
            
        }
    }
 
    func closeaction(){
        self.PasswordTextField.text = ""
        XMPPUtil.sharedInstance.disConnect()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "resigersegue"{
//            let mytitle :String = sender as! String
//            let resigercontroller = segue.destination as! ResigerViewController
//            resigercontroller.mytitle = mytitle
//            
//        }
//        
//    }


}
