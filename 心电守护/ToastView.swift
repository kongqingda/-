//
//  ToastView.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/31.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import UIKit
//弹窗工具
class ToastView : NSObject{
    
    static var instance : ToastView = ToastView()
    
    var windows = UIApplication.shared.windows
    let rv = UIApplication.shared.keyWindow?.subviews.first as UIView!
    
    //显示加载
    func showLoadingView(content:String, duration:CFTimeInterval=6) {
        clear()
        let screen = UIScreen.main.bounds
        
        //let backgroundview = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screen.width, height: screen.height))
        //backgroundview.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 0.4042433647)
        
        let frame = CGRect(x:0, y:0,width: 90, height:90)
        let loadingContainerView = UIView()
        loadingContainerView.layer.cornerRadius = 10
        loadingContainerView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.8)
        
        let indicatorWidthHeight :CGFloat = 36
        let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingIndicatorView.frame = CGRect(x:frame.width/2 - indicatorWidthHeight/2, y:frame.height/2 - indicatorWidthHeight/2-8, width:indicatorWidthHeight, height:indicatorWidthHeight)
        loadingIndicatorView.startAnimating()
        loadingContainerView.addSubview(loadingIndicatorView)
       // backgroundview.addSubview(loadingContainerView)
        
        var toastContentView : UILabel!
        let textwidth = 15*content.characters.count
        if textwidth < 90{
             toastContentView = UILabel(frame: CGRect(x:(frame.width-CGFloat(textwidth))/2, y:indicatorWidthHeight+(frame.height-indicatorWidthHeight)/2+5, width:CGFloat(textwidth), height:CGFloat(15)))
        }else{
              toastContentView = UILabel(frame: CGRect(x:0, y:indicatorWidthHeight+(frame.height-indicatorWidthHeight)/2, width:CGFloat(85), height:CGFloat(15)))
        }
        toastContentView.font = UIFont.systemFont(ofSize: 13)
        toastContentView.textColor = UIColor.white
        toastContentView.text = content
        toastContentView.textAlignment = NSTextAlignment.center
        loadingContainerView.addSubview(toastContentView)
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        window.frame = frame
        loadingContainerView.frame = frame
        
        window.windowLevel = UIWindowLevelAlert
        window.center = CGPoint(x: (rv?.center.x)!, y: (rv?.center.y)!)
        window.isHidden = false
        window.addSubview(loadingContainerView)
        windows.append(window)
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
        //loadingContainerView.layer.add(AnimationUtil.getToastAnimation(duration: 1), forKey: "animation")
        perform(#selector(removeToast(_:)), with: window, afterDelay: duration)
        
        
    }
    
    //弹窗图片文字
    func showToast(content:String , imageName:String="icon_cool", duration:CFTimeInterval=1.5) {
        clear()
        let textwidth = 15*content.characters.count
        let frame = CGRect(x:0,y: 0, width:textwidth, height:40)
        
        let toastContainerView = UIView()
        toastContainerView.layer.cornerRadius = 10
        toastContainerView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.7)
        
       // let iconWidthHeight :CGFloat = 36
        //let toastIconView = UIImageView(image: UIImage(named: imageName)!)
        //toastIconView.frame = CGRect(x:(frame.width - iconWidthHeight)/2, y:15, width:iconWidthHeight, height:iconWidthHeight)
        //toastContainerView.addSubview(toastIconView)
        
        let toastContentView = UILabel(frame: CGRect(x:0, y:0, width:frame.width, height:frame.height))
        toastContentView.font = UIFont.systemFont(ofSize: 13)
        toastContentView.textColor = UIColor.white
        toastContentView.text = content
        toastContentView.textAlignment = NSTextAlignment.center
        toastContainerView.addSubview(toastContentView)
        
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        window.frame = frame
        toastContainerView.frame = frame
        
        window.windowLevel = UIWindowLevelAlert
        window.center = CGPoint(x: (rv?.center.x)!, y: (rv?.center.y)!*10/10)
        window.isHidden = false
        window.addSubview(toastContainerView)
        windows.append(window)
        
        toastContainerView.layer.add(AnimationUtil.getToastAnimation(duration: duration), forKey: "animation")
        
        perform(#selector(removeToast(_:)), with: window, afterDelay: duration)
    }
    
    //移除当前弹窗
    func removeToast(_ sender: AnyObject) {
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        if let window = sender as? UIWindow {
            if let index = windows.index(where: { (item) -> Bool in
                return item == window
            }) {
                // print("find the window and remove it at index \(index)")
                windows.remove(at: index)
            }
        }else{
            // print("can not find the window")
        }
    }
    
    //清除所有弹窗
    func clear() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        windows.removeAll(keepingCapacity: false)
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
    }
    //显示系统Alert弹窗
    func showAlert(_ message : String, _ uiview : UIViewController) {
        let alert : UIAlertController = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title:"确定",style:.default){
            (alertAction) -> Void in
            uiview.dismiss(animated: true, completion: nil)
        }
        alert.addAction(OKAction)
        uiview.present(alert, animated: true, completion: nil)
    }
    
}


