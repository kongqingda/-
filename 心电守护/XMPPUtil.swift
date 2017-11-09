//
//  XMPPUtil.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/10/23.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import KissXML
import XMPPFramework
private let xmppUtilShareInstance = XMPPUtil()

class XMPPUtil: NSObject, XMPPStreamDelegate {
    var pwd : String!
    var isOpen : Bool = false
    var xmppjid : XMPPJID!
    var xs : XMPPStream?
    class var sharedInstance : XMPPUtil {
        return xmppUtilShareInstance
    }
    
    //建立通道
    func buildStream(){
        if xs == nil{
            xs = XMPPStream()
            xs?.addDelegate(self, delegateQueue: DispatchQueue.main)
        }
    }

    //发送上线状态
    func goOnline() {
        let p = XMPPPresence.init(type: "available")
         print("用户上线")
        ToastView.instance.showToast(content: "用户上线")
        xs!.send(p)
        getOfflineMsg()
    }
    
    //发送下线状态
    func goOffline() {
        let p = XMPPPresence(type: "unavailabe")
        ToastView.instance.showToast(content: "用户下线")
        print("用户下线")
        xs!.send(p)
        
    }
    
    //连接服务器(查看服务器是否可连接)
    func connect() -> Bool {
        //建立通道
        buildStream()
        //通道已经连接
        if xs!.isConnected() {
            return true
        }
        
        //取系统中保存的用户名/密码/服务器地址
        let userdefaults = UserDefaults.standard
        let username = userdefaults.string(forKey: "username")
        let password = userdefaults.string(forKey: "pwd")
        if (username != nil && password != nil) {
            
            //通道的用户名
            xmppjid = XMPPJID.init(user: username, domain: "xdsh.com", resource: nil)
            xs!.myJID = xmppjid   //XMPPJID.init(string: username)
            xs!.hostName = "171.221.207.147"
            xs!.hostPort = 5223 //正式端5223 调试端为 5222
            self.pwd = password
            do {
                try xs!.connect(withTimeout: 4000)
            } catch _ {
                ToastView.instance.showToast(content: "连接XMPP失败")
                return false
            }
            return true
            
        }
        return false
    }
    //断开连接
    func disConnect() {
        if xs != nil {
            if xs!.isConnected() {
                goOffline()
                xs!.disconnect()
            }
        }
        
    }
    
    //获取离线消息
    func getOfflineMsg(){
        do {
            let xmlstr : String = String.init(format: "<presence from='%@'><priority>1</priority></presence>", xmppjid.description)
            print(xmppjid.description)
            let iq : XMPPIQ = try XMPPIQ.init(xmlString: xmlstr)
            self.xs?.send(iq)
        } catch _ {
            
        }
        
        
    }
    //收到消息
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        //var msg = WXMessage()
        // 如果是聊天消息
        print("打印心电检测信息:")
        print(message)
        if message.isChatMessage() {
            
            //对方正在输入
            if message.elements(forName: "composing") != nil {
                //msg.isComposing = true
            }
            
            //离线消息
            if let delay = message.forName("delay") {
               // msg.isDelay = true
                let msgdelay = delay.stringValue
                
                do {
                    let dic  = try JSONSerialization.jsonObject(with: (msgdelay?.data(using: String.Encoding.utf8))!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    print(dic)
                    NotificationCenter.default.post(name: Notification.Name("msgbody"), object: dic)
                    let messageContent = dic["messageContent"] as! NSDictionary
                    let content = messageContent["content"] as! String
                    let properties = messageContent["properties"] as! NSDictionary
                    let dataId = properties["ecgID"] as! String
                    let sentTime = dic["sentTime"] as! Int64
                    let receiver = dic["receiver"] as! String
                    let ctrlType = messageContent["ctrlType"] as! String
                    let sender = dic["sender"] as! String
                    let data : diagnosismsg = diagnosismsg.init(dataId: Int32(dataId)!, properties: "nil", sentTime: sentTime, receiver:receiver, ctrlType: Int16(ctrlType)! , sender: sender, content: content, isread: false)
                    DiagnosisMsgDao.sharedInstance.create(data)
                    
                    ToastView.instance.showToast(content: "收到诊断信息,请在心电数据中查看")
                } catch _ {
                    ToastView.instance.showToast(content: "解析失败")
                    
                }
            }
            
            //消息正文
            if let body = message.forName("body") {
                let msgbody = body.stringValue
                print(body)
                
                do {
                    let dic  = try JSONSerialization.jsonObject(with: (body.stringValue?.data(using: String.Encoding.utf8))!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    print(dic)
                    NotificationCenter.default.post(name: Notification.Name("msgbody"), object: dic)
                    let messageContent = dic["messageContent"] as! NSDictionary
                    let content = messageContent["content"] as! String
                    let properties = messageContent["properties"] as! NSDictionary
                    let dataId = properties["ecgID"] as! String
                    let sentTime = dic["sentTime"] as! Int64
                    let receiver = dic["receiver"] as! String
                    let ctrlType = messageContent["ctrlType"] as! String
                    let sender = dic["sender"] as! String
                    let data : diagnosismsg = diagnosismsg.init(dataId: Int32(dataId)!, properties: "nil", sentTime: sentTime, receiver:receiver, ctrlType: Int16(ctrlType)! , sender: sender, content: content, isread: false)
                    DiagnosisMsgDao.sharedInstance.create(data)
                    
                    ToastView.instance.showToast(content: "收到诊断信息,请在心电数据中查看")
                } catch _ {
                    ToastView.instance.showToast(content: "解析失败")

                }
           
                
            }
        }
    }
    //收到状态
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        //我自己的用户名
        let myUser = sender.myJID.user
        
        //好友的用户名
        let user = presence.from().user
        
        //用户所在的域
        let domain = presence.from().domain
        
        //状态类型
        let pType = presence.type()
        
        //如果状态不是自己的
        if (user != myUser) {
            //状态保存的结构
            //var zt = Zhuangtai()
            
            //保存了状态的完整用户名
            // zt.name = user + "@" + domain
            
            //上线
            if pType == "available" {
                // zt.isOnline = true
                //ztdl?.isOn(zt)
                ToastView.instance.showToast(content: "在线状态")
                
            } else if pType == "unavailable" {
                //ztdl?.isOff(zt)
                 ToastView.instance.showToast(content: "下线状态")
                
            }
            
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
         print("已连接XMPPsocket")
    }
    //连接成功
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        isOpen = true
        do {
           
            //验证密码
            try xs?.authenticate(withPassword: pwd)
             print("已连接XMPP")
            
            
        } catch _ {
            print("验证失败")
        }
    }
    //验证密码
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        //上线
            goOnline()
            print("验证成功")
    }
   
}
