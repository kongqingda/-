//
//  PreferenceDAO.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/22.
//  Copyright © 2017年 qingda kong. All rights reserved.
//
import Foundation
public class PreferenceData : NSObject{
    var username : String?
    var userphone : Int?
    var usersex : Int?
    var usercase : String?
    var userpassword : Int?
    var birthday : String?
    var bindper : String?
    init(name : String? ,password : Int?,phone : Int?,sex : Int?,usercase : String?,birthday : String?,bindper:String?) {
        self.userpassword = password
        self.username = name
        self.usercase = usercase
        self.bindper = bindper
        self.birthday = birthday
        self.usersex  = sex
        self.userphone = phone
    }
    
}
