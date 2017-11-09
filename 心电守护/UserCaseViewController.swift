//
//  UserCaseViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/2.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class UserCaseViewController: UIViewController {
    var medicalHistory : String?
    @IBOutlet weak var CaseTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }
    func initView(){
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.CaseTextView.layer.cornerRadius = 5
        self.CaseTextView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.CaseTextView.layer.borderWidth = 0.5
        let userdefaults : UserDefaults = .standard
        medicalHistory = userdefaults.string(forKey: "medicalHistory")
        CaseTextView.text = medicalHistory
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        medicalHistory = self.CaseTextView.text
        NotificationCenter.default.post(name: Notification.Name("changemedicalHistory"), object: medicalHistory)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func deleteAction(_ sender: Any) {
        medicalHistory = ""
        self.CaseTextView.text = medicalHistory
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
