//
//  AnimationUtil.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/31.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import Foundation
import UIKit
class AnimationUtil{
    
    //弹窗动画
    static func getToastAnimation(duration:CFTimeInterval = 1.5) -> CAAnimation{
        // 大小变化动画
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0, 0.1, 0.9, 1]
        scaleAnimation.values = [0.5, 1, 1,0.5]
        scaleAnimation.duration = duration
        
        // 透明度变化动画
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimaton.keyTimes = [0, 0.8, 1]
        opacityAnimaton.values = [0.5, 1, 0]
        opacityAnimaton.duration = duration
        
        // 组动画
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimaton]
        //动画的过渡效果1. kCAMediaTimingFunctionLinear//线性 2. kCAMediaTimingFunctionEaseIn//淡入 3. kCAMediaTimingFunctionEaseOut//淡出4. kCAMediaTimingFunctionEaseInEaseOut//淡入淡出 5. kCAMediaTimingFunctionDefault//默认
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.duration = duration
        animation.repeatCount = 0// HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    //动画2
    static func getImageChangeAnimation(duration:CFTimeInterval = 1) -> CAAnimation{
       
        // 透明度变化动画
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimaton.keyTimes = [0, 0.2,0.5,0.8, 1]
        opacityAnimaton.values = [1, 0.5, 0,0.5,1]
        opacityAnimaton.duration = duration
        
        //路径变化
        let screenSize  = UIScreen.main.bounds.size;
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        let path = CGMutablePath()
        path.move(to: CGPoint.init(x: screenSize.width/2, y: screenSize.height/2))
        path.addLine(to: CGPoint.init(x: 0, y: screenSize.height/2))
        path.move(to: CGPoint.init(x: screenSize.width, y: screenSize.height/2))
        path.addLine(to: CGPoint.init(x: screenSize.width/2, y: screenSize.height/2))
        positionAnimation.path = path
        positionAnimation.duration = duration
        
        // 组动画
        let animation = CAAnimationGroup()
        animation.animations = [positionAnimation,opacityAnimaton]
        //动画的过渡效果1. kCAMediaTimingFunctionLinear//线性 2. kCAMediaTimingFunctionEaseIn//淡入 3. kCAMediaTimingFunctionEaseOut//淡出4. kCAMediaTimingFunctionEaseInEaseOut//淡入淡出 5. kCAMediaTimingFunctionDefault//默认
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.duration = duration
        animation.repeatCount = 0// HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    //动画3
    static func getImagedataAnimation(duration:CFTimeInterval = 1) -> CAAnimation{
        
      
        
        // 大小变化动画
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0, 0.5,0.7,0.8,0.9, 1]
        scaleAnimation.values = [0.2,0.6,1,0.7, 0.5,0.2]
        scaleAnimation.duration = duration
        
        //路径变化
        let screenSize  = UIScreen.main.bounds.size;
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        let path = CGMutablePath()
        path.move(to: CGPoint.init(x: screenSize.width/2+90, y: screenSize.height/2))
        path.addLine(to: CGPoint.init(x: screenSize.width/2+40, y: screenSize.height/2))
        path.addLine(to: CGPoint.init(x: screenSize.width/2, y: screenSize.height/2))
        path.addLine(to: CGPoint.init(x: screenSize.width/2-40, y: screenSize.height/2))
        path.addLine(to: CGPoint.init(x: screenSize.width/2-90, y: screenSize.height/2))
        path.move(to: CGPoint.init(x: screenSize.width/2+90, y: screenSize.height/2))
        positionAnimation.keyTimes = [0, 0.5,0.7,0.8,0.9, 1]
        positionAnimation.path = path
        positionAnimation.duration = duration
        
        // 组动画
        let animation = CAAnimationGroup()
        animation.animations = [positionAnimation,scaleAnimation]
        //动画的过渡效果1. kCAMediaTimingFunctionLinear//线性 2. kCAMediaTimingFunctionEaseIn//淡入 3. kCAMediaTimingFunctionEaseOut//淡出4. kCAMediaTimingFunctionEaseInEaseOut//淡入淡出 5. kCAMediaTimingFunctionDefault//默认
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    
        animation.duration = duration
        animation.repeatCount = 0 // HUGE
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    //向⬅️滑动
    static func getleftAnimation(view: UIView,duration:CFTimeInterval = 0.5) -> CAAnimation{
        
        // 透明度变化动画
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimaton.keyTimes = [0,0.5, 1]
        opacityAnimaton.values = [0.5,0.8,1]
        opacityAnimaton.duration = duration
        
        //路径变化
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        let path = CGMutablePath()
        path.move(to: CGPoint.init(x: view.frame.width/2, y: view.frame.height))
        path.addLine(to: CGPoint.init(x: 0, y: view.frame.height))
        path.move(to: CGPoint.init(x: view.frame.width+view.frame.width/2, y: view.frame.height))
        path.addLine(to: CGPoint.init(x: view.frame.width/2, y: view.frame.height))
        positionAnimation.path = path
        positionAnimation.duration = duration
        
        // 组动画
        let animation = CAAnimationGroup()
        animation.animations = [opacityAnimaton,positionAnimation]
        //动画的过渡效果1. kCAMediaTimingFunctionLinear//线性 2. kCAMediaTimingFunctionEaseIn//淡入 3. kCAMediaTimingFunctionEaseOut//淡出4. kCAMediaTimingFunctionEaseInEaseOut//淡入淡出 5. kCAMediaTimingFunctionDefault//默认
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.duration = duration
        animation.repeatCount = 0// HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
        
    }
    //向➡️滑动
    static func getrightAnimation(view: UIView,duration:CFTimeInterval = 0.5) -> CAAnimation{
        
        // 透明度变化动画
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimaton.keyTimes = [0,0.5, 1]
        opacityAnimaton.values = [0.5,0.8,1]
        opacityAnimaton.duration = duration
        
        //路径变化
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        let path = CGMutablePath()
        path.move(to: CGPoint.init(x: view.frame.width/2, y: view.frame.height))
        path.addLine(to: CGPoint.init(x: view.frame.width, y: view.frame.height))
        path.move(to: CGPoint.init(x: -view.frame.width/2, y: view.frame.height))
        path.addLine(to: CGPoint.init(x: view.frame.width/2, y: view.frame.height))
        positionAnimation.path = path
        positionAnimation.duration = duration
      
        
        // 组动画
        let animation = CAAnimationGroup()
        animation.animations = [opacityAnimaton,positionAnimation]
        //动画的过渡效果1. kCAMediaTimingFunctionLinear//线性 2. kCAMediaTimingFunctionEaseIn//淡入 3. kCAMediaTimingFunctionEaseOut//淡出4. kCAMediaTimingFunctionEaseInEaseOut//淡入淡出 5. kCAMediaTimingFunctionDefault//默认
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.duration = duration
        animation.repeatCount = 0// HUGE
        animation.isRemovedOnCompletion = false
        
        return animation
        
    }
}

