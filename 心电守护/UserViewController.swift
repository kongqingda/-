//
//  UserViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class UserViewController: UIViewController ,UITextViewDelegate{

    @IBOutlet weak var text_bttomlength: NSLayoutConstraint!
    @IBOutlet weak var birthdaybtn: UIButton!
    @IBOutlet weak var NameLabel: UITextField!
    @IBOutlet weak var GroupBoy: UIButton!
    @IBOutlet weak var GroupGirl: UIButton!
    @IBOutlet weak var WeightLabel: UITextField!
    @IBOutlet weak var HeightLabel: UITextField!

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var CaseLabel: UITextView!
    var choicegender : Int?
    var phone : String!
    var netutil : netUtil!
    let dateformatter : DateFormatter = DateFormatter()
    var birthday : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.CaseLabel.delegate = self
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        dateformatter.dateFormat = "YYYY-MM-dd"
        netutil = netUtil.sharedInstance
      
                // Do any additional setup after loading the view.
        //NotificationCenter.default.addObserver(self, selector: #selector(changebirthday(notification:)), name: Notification.Name("datepicker"), object: nil)
  
        let userdefault : UserDefaults = .standard
        phone = userdefault.string(forKey: "phone")!
        let username = userdefault.string(forKey: "username")
        choicegender = userdefault.integer(forKey: "gender")
        birthday = userdefault.string(forKey: "birthday")
        let height = userdefault.integer(forKey: "height")
        let weight = userdefault.integer(forKey: "weight")
        let medicalHistory = userdefault.string(forKey: "medicalHistory")
        
        NameLabel.text = username
        WeightLabel.text = weight.description
        HeightLabel.text = height.description
        birthdaybtn.setTitle(birthday, for: .normal)
        CaseLabel.text = medicalHistory
        if choicegender == 0{
            GroupBoy.setImage(UIImage.init(named: "已选中.png"), for: .normal)
            GroupGirl.setImage(UIImage.init(named: "未选中.png"), for: .normal)
        }else{
            GroupBoy.setImage(UIImage.init(named: "未选中.png"), for: .normal)
            GroupGirl.setImage(UIImage.init(named: "已选中.png"), for: .normal)
        }
        //键盘的打开和关闭通知
        NotificationCenter.default.addObserver(self, selector: #selector(showkeyboard), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hindkeyboard), name: Notification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(queryPersonalInfo(notification:)), name: Notification.Name("queryPersonalInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(savePersonalInfo(notification:)), name: Notification.Name("savePersonalInfo"), object: nil)
        netutil.queryPersonalInfo(phone: phone)

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SaveItemAction(_ sender: Any) {
        let username:String? = NameLabel.text
        let weight : Int! = Int(WeightLabel.text!)
        let height : Int! =  Int(HeightLabel.text!)
        let birthday:String? = birthdaybtn.title(for: .normal)
        let medicalHistory:String? =  CaseLabel.text
        netutil.savePersonalInfo(name: username, gender: choicegender, height: height, weight: weight, medicalHistory: medicalHistory, phone: phone, birthday: birthday)
    }
    
    //查询个人信息的通知
    func queryPersonalInfo(notification:Notification)  {
        let json:NSDictionary =  notification.object as! NSDictionary
        ToastView.instance.clear()
        let result = json["result"] as! Int
        if result == 0{
            let info = json["info"] as! NSDictionary
            let name:String? = info["name"] as? String
            let username:String? = info["username"] as? String
            let birthday:String? = info["birthday"] as? String
            let gender:Int? = info["gender"] as? Int
            let medicalHistory:String? = info["medicalHistory"] as? String
            let weight:Int? = info["weight"] as? Int
            let height:Int? = info["height"] as? Int
            NameLabel.text = username
            WeightLabel.text = weight?.description
            HeightLabel.text = height?.description
            birthdaybtn.setTitle(birthday, for: .normal)
            CaseLabel.text = medicalHistory
            if choicegender == 0{
                GroupBoy.setImage(UIImage.init(named: "已选中.png"), for: .normal)
                GroupGirl.setImage(UIImage.init(named: "未选中.png"), for: .normal)
            }else{
                GroupBoy.setImage(UIImage.init(named: "未选中.png"), for: .normal)
                GroupGirl.setImage(UIImage.init(named: "已选中.png"), for: .normal)
            }

            

            ToastView.instance.showToast(content: "个人信息更新")
            let userdefault : UserDefaults = .standard
            //userdefault.set(name, forKey: "name")
            userdefault.set(birthday, forKey: "birthday")
             userdefault.set(gender, forKey: "gender")
             userdefault.set(medicalHistory, forKey: "medicalHistory")
             userdefault.set(weight, forKey: "weight")
             userdefault.set(height, forKey: "height")
            userdefault.set(username, forKey: "username")
            userdefault.synchronize()
            
            
            
            
        }else{
            
            ToastView.instance.showToast(content: json["remark"] as! String)
            
        }

    }
    
    //保存个人信息的通知
    func savePersonalInfo(notification:Notification) {
        let json:NSDictionary =  notification.object as! NSDictionary
        ToastView.instance.clear()
        let result = json["result"] as! Int
        if result == 0{
            ToastView.instance.showToast(content: "保存成功")
            let username : String? = NameLabel.text!
            let weight : Int? = Int(WeightLabel.text!)
            let height : Int? = Int(HeightLabel.text!)
            let birthday : String? = birthdaybtn.title(for: .normal)
            let medicalHistory : String? =  CaseLabel.text!
            let userdefault : UserDefaults = .standard
            userdefault.set(username, forKey: "username")
            userdefault.set(birthday, forKey: "birthday")
            userdefault.set(choicegender, forKey: "gender")
            userdefault.set(medicalHistory, forKey: "medicalHistory")
            userdefault.set(weight, forKey: "weight")
            userdefault.set(height, forKey: "height")
            userdefault.synchronize()
            //self.dismiss(animated: true, completion: nil)
            
            
        }else{
            
            ToastView.instance.showToast(content: json["remark"] as! String)
            
        }

    }

    @IBAction func boyaction(_ sender: Any) {
        
        GroupGirl.setImage(UIImage.init(named: "未选中.png"), for: .normal)
        GroupBoy.setImage(UIImage.init(named: "已选中.png"), for: .normal)
        
               choicegender = 0

        
    }
    @IBAction func girlaction(_ sender: Any) {
        
        GroupBoy.setImage(UIImage.init(named: "未选中.png"), for: .normal)
        GroupGirl.setImage(UIImage.init(named: "已选中.png"), for: .normal)

         choicegender = 1
    }
    @IBAction func birthdayaction(_ sender: Any) {
        let datealter  = UIAlertController.init(title: "选择时间", message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datepicker : UIDatePicker = UIDatePicker.init(frame: CGRect(x:0,y:30,width:self.view.frame.width-20,height:180))
        
        datepicker.datePickerMode = .date
        if self.birthday != nil{
            datepicker.date = dateformatter.date(from: birthday!)!
        }
        datepicker.maximumDate = Date()
        datepicker.minimumDate = dateformatter.date(from: "1880-01-01")!
        
        let closeaction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let Okaction = UIAlertAction.init(title: "确定", style: .default) { (UIAction) in
            
            let theDate : Date = datepicker.date
            let datestr : String = self.dateformatter.string(from: theDate)
            self.birthdaybtn.setTitle(datestr, for: .normal)
            datealter.dismiss(animated: true, completion: nil)
        }
        
        datealter.addAction(Okaction)
        datealter.addAction(closeaction)
        datealter.view.addSubview(datepicker)
        self.present(datealter, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func changebirthday(notification: Notification){
        let datestr = notification.object as! String
        birthdaybtn.setTitle(datestr, for: .normal)
    }
    
    func showkeyboard(){
        
    }
    func hindkeyboard(){
        
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
          self.text_bttomlength.constant = 160
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.text_bttomlength.constant = 7
    }
       
}
