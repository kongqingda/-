//
//  AboutSoftViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/11/7.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit



class AboutSoftViewController: UIViewController ,UIScrollViewDelegate{
    
    @IBOutlet weak var closebtn: UIButton!
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var scrollview: UIScrollView!
    var timer : Timer!
    var imageview1 : UIImageView!
    var imageview2 : UIImageView!
    var imageview3 : UIImageView!
    var imageview4 : UIImageView!
    var imageview5 : UIImageView!
    var imageview6 : UIImageView!
    let S_WIDTH:CGFloat = UIScreen.main.bounds.size.width
    var S_HEIGHT:CGFloat!
    let pagenum: Int = 4
    var isfirst : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollview.delegate = self
        S_HEIGHT = UIScreen.main.bounds.size.height
        self.scrollview.contentSize = CGSize(width:S_WIDTH*CGFloat(pagenum),height:S_HEIGHT)
        self.scrollview.frame = self.view.frame
       initView()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func initView(){
        self.closebtn.isHidden = true
        let userdefaults : UserDefaults = .standard
        isfirst = userdefaults.bool(forKey: "isfirst")
        
        imageview1 = UIImageView(frame:CGRect(x:S_WIDTH*0,y:0.0,width:S_WIDTH,height:S_HEIGHT))
        imageview1.image = UIImage(named: "导航1.png")
        self.scrollview.addSubview(imageview1)
        
        imageview2 = UIImageView(frame:CGRect(x:S_WIDTH*1,y:0.0,width:S_WIDTH,height:S_HEIGHT))
        imageview2.image = UIImage(named: "导航2.png")
        self.scrollview.addSubview(imageview2)
        
        imageview3 = UIImageView(frame:CGRect(x:S_WIDTH*2,y:0.0,width:S_WIDTH,height:S_HEIGHT))
        imageview3.image = UIImage(named: "导航3.png")
        self.scrollview.addSubview(imageview3)
        
        imageview4 = UIImageView(frame:CGRect(x:S_WIDTH*3,y:0.0,width:S_WIDTH,height:S_HEIGHT))
        imageview4.image = UIImage(named: "导航4.png")
        self.scrollview.addSubview(imageview4)
        
        pagecontrol.numberOfPages = pagenum
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(imagere), userInfo: nil, repeats: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        timer.invalidate()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
         timer.invalidate()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollview.contentOffset
        self.pagecontrol.currentPage = Int(offset.x/S_WIDTH)
        if self.pagecontrol.currentPage == pagenum-1 && !isfirst{
            self.closebtn.isHidden = false
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true) {
            let userdefaults : UserDefaults = .standard
            userdefaults.set(true, forKey: "isfirst")
            userdefaults.synchronize()
        }
    }
    @IBAction func pagechange(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            let Whichpage = self.pagecontrol.currentPage
            self.scrollview.contentOffset = CGPoint(x:self.S_WIDTH * CGFloat(Whichpage),y:0.0)
        }
        
    }
    //实现图片轮播
    func imagere(){
        var Whichpage = self.pagecontrol.currentPage
        Whichpage = Whichpage+1
        if Whichpage<pagenum {
            self.scrollview.contentOffset = CGPoint(x:S_WIDTH * CGFloat(Whichpage),y:0.0)
            if Whichpage == pagenum-1 && !isfirst{
                self.closebtn.isHidden = false
            }
        }else{
            timer.invalidate()
            
        }
        
    }
    
}

