//
//  UserTableViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/2.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController ,UIPickerViewDelegate,UIPickerViewDataSource{
  

    @IBOutlet weak var CaseLabel: UITextView!
    @IBOutlet weak var BirthdayLabel: UILabel!
    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var WeightLabel: UILabel!
    @IBOutlet weak var SexLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var casecell: UITableViewCell!
    
    var choicegender : Int?
    var phone : String!
    var netutil : netUtil!
    let dateformatter : DateFormatter = DateFormatter()
    var birthday : String?
    var name : String?
    var weight : Int?
    var height : Int?
    var medicalHistory : String?
    var contentArray : [String] = []
    var choicepicker : UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //casecell.frame.size.height = casecell.frame.size.height + 100
        dateformatter.dateFormat = "YYYY-MM-dd"
        netutil = netUtil.sharedInstance
        
        getloaclData()
        initView()
        initNotification()
        if AppDelegate.netstyle != .notReachable{
            netutil.queryPersonalInfo(phone: phone)
        }
    }
    func initView(){
        if height == nil{
            height = 0
        }
        if weight == nil{
            weight = 0
        }
        if name == nil{
            name = " "
        }
        if birthday == nil{
            birthday = " "
        }
        if medicalHistory == nil{
            medicalHistory = " "
        }
        if choicegender == nil{
            choicegender = 1
        }
        NameLabel.text = name
        WeightLabel.text = weight?.description
        HeightLabel.text = height?.description
        if choicegender == 0{
            SexLabel.text = "女"
        }else{
            SexLabel.text = "男"
        }
        CaseLabel.text = medicalHistory
        BirthdayLabel.text = birthday
    }
    func initNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(queryPersonalInfo(_:)), name: Notification.Name("queryPersonalInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(savePersonalInfo(_:)), name: Notification.Name("savePersonalInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changemedicalHistory(_:)), name: Notification.Name("changemedicalHistory"), object: nil)
    }
    
    
    func getloaclData(){
        let userdefault : UserDefaults = .standard
        phone = userdefault.string(forKey: "phone")!
        name = userdefault.string(forKey: "name")
        choicegender = userdefault.integer(forKey: "gender")
        birthday = userdefault.string(forKey: "birthday")
        height = userdefault.integer(forKey: "height")
        weight = userdefault.integer(forKey: "weight")
        medicalHistory = userdefault.string(forKey: "medicalHistory")
    }
    func setLocalData(){
        let userdefault : UserDefaults = .standard
        userdefault.set(name, forKey: "name")
        userdefault.set(birthday, forKey: "birthday")
        userdefault.set(choicegender, forKey: "gender")
        userdefault.set(medicalHistory, forKey: "medicalHistory")
        userdefault.set(weight, forKey: "weight")
        userdefault.set(height, forKey: "height")
        userdefault.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //查询个人信息的通知
    func queryPersonalInfo(_ notification:Notification)  {
        let json:NSDictionary =  notification.object as! NSDictionary
        ToastView.instance.clear()
        let result = json["result"] as! Int
        if result == 0{
            let info = json["info"] as! NSDictionary
            name = info["name"] as? String
            let username:String? = info["username"] as? String
            birthday = info["birthday"] as? String
            choicegender = info["gender"] as? Int
            medicalHistory = info["medicalHistory"] as? String
            weight = info["weight"] as? Int
            height = info["height"] as? Int
            if height == nil{
                height = 0
            }
            if weight == nil{
                weight = 0
            }
            if name == nil{
                name = " "
            }
            if birthday == nil{
                birthday = " "
            }
            if medicalHistory == nil{
                medicalHistory = "请填写真实的病历情况，比如心脏病等"
            }
            if choicegender == nil{
                choicegender = 1
            }
            initView()
            setLocalData()
        }else{
            ToastView.instance.showToast(content: json["remark"] as! String)
        }
        
    }
    //保存个人信息的通知
    func savePersonalInfo(_ notification:Notification) {
        let json:NSDictionary =  notification.object as! NSDictionary
        ToastView.instance.clear()
        let result = json["result"] as! Int
        if result == 0{
            ToastView.instance.showToast(content: "保存成功")
            name = NameLabel.text
            weight = Int(WeightLabel.text!)
            height = Int(HeightLabel.text!)
            medicalHistory = CaseLabel.text
            if SexLabel.text == "男"{
                choicegender = 1
            }
            if SexLabel.text == "女"{
                choicegender = 0
            }
            setLocalData()
            
        }else{
            
            ToastView.instance.showToast(content: json["remark"] as! String)
            
        }
        
    }
    
    func changemedicalHistory(_ notification : Notification){
         self.medicalHistory =  notification.object as! String
        self.CaseLabel.text = self.medicalHistory
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = tableView.cellForRow(at: indexPath)
//        return (cell?.frame.size.height)!
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        switch section {
        case 0:
             showEditAlert()
        case 1:
            showChoiceAlert(style: indexPath.row+1)
        default:
            break
        }
       
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 30
        }
        return 20
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    @IBAction func saveAction(_ sender: Any) {
        netutil.savePersonalInfo(name: name, gender: choicegender, height: height, weight: weight, medicalHistory: medicalHistory, phone: phone, birthday: birthday)
    }
    
    //弹出带edit的编辑窗
    func showEditAlert(){
        let alert : UIAlertController = UIAlertController.init(title: "姓名", message: nil, preferredStyle: .alert)
        alert.addTextField { (edittext) in
            edittext.placeholder = "请输入..."
            edittext.keyboardType = .numberPad
            edittext.keyboardType = .default
            edittext.textAlignment = .center
            edittext.text = self.name
        }
        let OKAction = UIAlertAction(title:"确定",style:.default){
            (alertAction) -> Void in
            self.name = alert.textFields?[0].text
            self.NameLabel.text = self.name
        }
        let cancelAction = UIAlertAction(title:"取消",style:.default){
            (alertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //弹出选择框
    func showChoiceAlert(style : Int){
        contentArray.removeAll()
        var title : String!
        var message : String!
        var datepicker : UIDatePicker!
        var choiceindex : Int = 0
        var choiceString : String = "1"
        switch style {
        case 1:
            title = "选择性别"
            message =  "\n\n\n\n"
            contentArray = ["男","女"]
            choicepicker = UIPickerView.init(frame: CGRect(x:0,y:30,width:self.view.frame.width-20,height:100))
            choicepicker.delegate = self
            choicepicker.dataSource = self
            if choicegender == 0{
                 choiceString = "女"
            }
            if choicegender == 1{
                choiceString = "男"
            }
           
        case 2:
            title = "选择体重(Kg)"
            message = "\n\n\n\n\n\n\n"
            for i in 35...150{
                contentArray.append(i.description)
            }
            choiceString = (weight?.description)!
            choicepicker = UIPickerView.init(frame: CGRect(x:0,y:30,width:self.view.frame.width-20,height:180))
            choicepicker.delegate = self
            choicepicker.dataSource = self
        case 3:
            title = "选择身高(cm)"
            message = "\n\n\n\n\n\n\n"
            for i in 100...250{
                contentArray.append(i.description)
            }
            choiceString = (height?.description)!
            choicepicker = UIPickerView.init(frame: CGRect(x:0,y:30,width:self.view.frame.width-20,height:180))
            choicepicker.delegate = self
            choicepicker.dataSource = self
        case 4:
            title = "选择生日"
            message = "\n\n\n\n\n\n\n"
            datepicker = UIDatePicker.init(frame: CGRect(x:0,y:30,width:self.view.frame.width-20,height:180))
            datepicker.datePickerMode = .date
            if self.birthday != nil{
                datepicker.date = dateformatter.date(from: birthday!)!
            }
            datepicker.maximumDate = Date()
            datepicker.minimumDate = dateformatter.date(from: "1880-01-01")!
        default:
            break
        }
        if contentArray.contains(choiceString){
            choiceindex = contentArray.index(of: choiceString)!
            choicepicker.selectRow(choiceindex, inComponent: 0, animated: true)
        }
        
        let datealter  = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
       
        let closeaction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let Okaction = UIAlertAction.init(title: "确定", style: .default) { (UIAction) in
            switch style{
            case 1:
                if self.contentArray[self.choicepicker.selectedRow(inComponent: 0)] == "男"{
                    self.choicegender = 1
                }else{
                    self.choicegender = 0
                }
                self.SexLabel.text = self.contentArray[self.choicepicker.selectedRow(inComponent: 0)]
            case 2:
                self.weight = Int(self.contentArray[self.choicepicker.selectedRow(inComponent: 0)])
                self.WeightLabel.text = self.weight?.description
            case 3:
                self.height = Int(self.contentArray[self.choicepicker.selectedRow(inComponent: 0)])
                self.HeightLabel.text = self.height?.description
            case 4:
                let theDate : Date = datepicker.date
                self.birthday = self.dateformatter.string(from: theDate)
                self.BirthdayLabel.text = self.birthday
            default:
                break
            }
            datealter.dismiss(animated: true, completion: nil)
        }
        
        datealter.addAction(Okaction)
        datealter.addAction(closeaction)
        if style == 4{
             datealter.view.addSubview(datepicker)
        }else{
             datealter.view.addSubview(choicepicker)
        }
       
        self.present(datealter, animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contentArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return contentArray[row]
    }
    

}
