//
//  ECGDataViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/9/13.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class ECGDataViewController: UIViewController {

    
    @IBOutlet weak var enddatelabel: UILabel!
    @IBOutlet weak var startdatelabel: UILabel!
    @IBOutlet weak var dataslider: UISlider!
    @IBOutlet weak var drawlineview: DrawLineView!
    @IBOutlet weak var datetitlelabel: UILabel!
    @IBOutlet weak var drawviewheight: NSLayoutConstraint!
    @IBOutlet weak var scalelabel: UILabel!
    
    @IBOutlet weak var drawbackview: DrawBackView!
    var filepath : String = ""
    var datestr : String = ""
    var startdate : String = ""
    var enddate : String = ""
    var filedao : FiledocmDao = FiledocmDao()
    var data : Data = Data()
    var currentvalue : Float = 0.0
    var datacount : Float = 0.0
    var pervalue : Float = 0.0
    var currentloc : Int = 0
    var alldata : Array<UInt8> = []
    var drawlist : Array<Int> = []
    var currentdrawlist : Array<Int> = []
    var viewwidth : CGFloat = 0.0
    let toastview : ToastView = ToastView.instance
    var timer : Timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        drawlineview.backgroundColor = #colorLiteral(red: 1, green: 0.150029252, blue: 0, alpha: 0)//设置背景透明
        let screenwidth = UIScreen.main.bounds.size.width
        drawviewheight.constant = CGFloat(11)*screenwidth/CGFloat(20)
        
        drawbackview.setNeedsDisplay()
        drawlineview.setNeedsDisplay()
        viewwidth = drawlineview.viewwidth
        toastview.showLoadingView(content: "正在加载...")
        datetitlelabel.text = datestr
        startdatelabel.text = startdate
        enddatelabel.text = enddate
        filedao = FiledocmDao.init()
        //创建Pan手势识别器
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(foundPan(_:)))
        //设置Pan手势识别器属性
        recognizer.minimumNumberOfTouches = 1
        recognizer.maximumNumberOfTouches = 1
        
        //Pan手势识别器关联到imageView
        self.drawlineview.addGestureRecognizer(recognizer)
        //设置开启用户事件
        self.drawlineview.isUserInteractionEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(initview), userInfo: nil, repeats: false)
        
           }
    
    
    func initview(){
        if filedao.readfile(filename: filepath) != nil{
            data = filedao.readfile(filename: filepath)!
        }
        // ECG-15730201534-TH802-2017-09-13-11/15/57
        // Do any additional setup after loading the view.
        if 5*data.count/16 <= drawlineview.widthmax{
            dataslider.value = 1.0
            dataslider.isEnabled = false
            self.drawlineview.isUserInteractionEnabled = false
        }
        analysisdata()
        viewwidth = drawlineview.frame.size.width
        pervalue = Float(drawlineview.widthmax)/Float(viewwidth)
        draw()
        toastview.clear()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slideraction(_ sender: Any) {
        currentvalue = dataslider.value
        currentloc = Int(currentvalue*Float(drawlist.count-drawlineview.widthmax))
        draw()
    }

    @IBAction func shareaction(_ sender: Any) {
        
        self.view.snapshotView(afterScreenUpdates: true)
        let shareimage = createImageWithView(view: self.view)
        
        let shareViewController : UIActivityViewController = UIActivityViewController.init(activityItems: [shareimage], applicationActivities: nil)
        shareViewController.excludedActivityTypes = [UIActivityType.airDrop]
        let popover :UIPopoverPresentationController  = shareViewController.popoverPresentationController!;
        if (popover != nil) {
            popover.sourceView = self.view;
            popover.permittedArrowDirections = .up;
        }
        self.present(shareViewController, animated: true, completion: nil)
    
    }
    
    //实现截屏的方法
    func createImageWithView(view : UIView) -> UIImage
    {
    
        let s : CGSize = self.view.bounds.size;
    
        //第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，设置为[UIScreen mainScreen].scale可以保证转成的图片不失真。
        UIGraphicsBeginImageContextWithOptions(s, false, UIScreen.main.scale)
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        
        UIGraphicsEndImageContext();
    
        return image;
    
    }
    
    var beforeloc : CGPoint = CGPoint.init(x: 0, y: 0)
    
    func foundPan(_ sender: UIPanGestureRecognizer) {
        
        print(sender.state)
        let location = sender.location(in: sender.view!)
        if sender.state == .began{
            beforeloc = location
        }
        if sender.state != .ended && sender.state != .failed{
            let movewidth =  beforeloc.x - location.x
            print(movewidth)
            dataslider.value = dataslider.value+pervalue*Float(movewidth)/Float(drawlist.count - drawlineview.widthmax)
            slideraction(self)
            beforeloc = location
        }else{
            beforeloc = location
        }
    }
    
    func analysisdata(){
        alldata = [UInt8](data)
        let k : Int = Int(ceil(Double(alldata.count/16)))
        if k > 0{
            for s in 0 ... k{
                if alldata.count>=16{
                    
                    for m  in 0 ..< 8{
                        let perdata =  (Int16(alldata[m*2+1]) & 0xff) << 8  | ((Int16(alldata[m*2]) & 0xff))//将两个8位数据组合
                        
                        if m < 5 {
                            drawlist.append(Int(perdata))
                            
                        }
                        
                    }
                    alldata.removeSubrange(0..<16)
                }
            }
        }

        
    }
    
    func draw(){
        currentdrawlist.removeAll()
        if drawlist.count>=drawlineview.widthmax{
            for i in currentloc ..< currentloc+drawlineview.widthmax{
                currentdrawlist.append(drawlist[i])
            }
        }else{
            currentdrawlist = drawlist
        }
       
        self.drawlineview.drawData = currentdrawlist
        self.drawlineview.setNeedsDisplay()
    }
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    @IBAction func pinchgestureaction(_ sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        print(drawlineview.scale)
        if sender.state != .ended || sender.state != .failed{
            if sender.scale>1.5{
                if  drawlineview.scale == 10{
                    drawlineview.scale = drawlineview.scale*2
                    drawlineview.setNeedsDisplay()
                    scalelabel.text = "增益：20mm/mv"
                }
            }
            if sender.scale>2.0{
                if  drawlineview.scale == 20{
                    drawlineview.scale = drawlineview.scale*2
                    drawlineview.setNeedsDisplay()
                    scalelabel.text = "增益：40mm/mv"
                }
            }
            if sender.scale < 0.8{
                if  drawlineview.scale == 40{
                    drawlineview.scale = drawlineview.scale/2
                    drawlineview.setNeedsDisplay()
                     scalelabel.text = "增益：20mm/mv"
                }
            }
            if sender.scale < 0.6{
                if  drawlineview.scale == 20{
                    drawlineview.scale = drawlineview.scale/2
                    drawlineview.setNeedsDisplay()
                    scalelabel.text = "增益：10mm/mv"
                }
            }
        }else{
            sender.scale = 1
        }
    }
    

}
