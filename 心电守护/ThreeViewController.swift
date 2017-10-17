//
//  ThreeViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Charts


class ThreeViewController: UIViewController,ChartViewDelegate{

    

    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var timetitlelabel: UILabel!
    @IBOutlet weak var steplabel: UILabel!
    let dateformatter : DateFormatter = DateFormatter()
    let toastview : ToastView = ToastView.instance
    
    @IBOutlet weak var barchart: BarChartView!
    var xAxis : XAxis!
    var yAxis : YAxis!
    var chartdata : [Int] = []
    var num : Int  = 24
    var timer : Timer  = Timer()
    var daydata : [BarChartDataEntry] = []
    var weekdata : [BarChartDataEntry] = []
    var monthdata : [BarChartDataEntry] = []
    var todaystepnum : Int64 = 0
    var dateFormatter : DateFormatter = DateFormatter()
    let filedao : FiledocmDao =  FiledocmDao.init()
    let sensordao : SensorDataDao = SensorDataDao.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        //self.tabBarController?.tabBar.selectedImageTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        BleDataAnalysis.shareInstance
        // Do any additional setup after loading the view.
        dateformatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date : Date  = Date()
        timetitlelabel.text = dateformatter.string(from: date)
        //BleTools.sharedInstance.managerdelegate = self
        //MainController.bletools.managerdelegate = self
        initchartview()
        NotificationCenter.default.addObserver(self, selector: #selector(revTodayStep(_:)), name: Notification.Name("gettodaystep"), object: nil)
    }
    //初始化barchartview
    func initchartview() {
    
        self.barchart.delegate = self
        self.barchart.noDataText = "没有数据显示，请刷新试试"
        self.barchart.drawValueAboveBarEnabled = true//数值显示在柱形的上面还是下面
        self.barchart.drawBarShadowEnabled = false;//是否绘制柱形的阴影背景
        self.barchart.scaleYEnabled = false;//取消Y轴缩放
        self.barchart.doubleTapToZoomEnabled = false;//取消双击缩放
        self.barchart.dragEnabled = true;//启用拖拽图表
        self.barchart.dragDecelerationEnabled = true;//拖拽后是否有惯性效果
        self.barchart.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数
        self.barchart.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.barchart.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.barchart.gridBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.barchart.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.barchart.borderLineWidth = 0.2
        self.barchart.drawGridBackgroundEnabled = false
        self.barchart.gridBackgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let l : Legend = self.barchart.legend
        l.enabled = false
        
        self.barchart.chartDescription?.text = "计步信息"
        
        xAxis = self.barchart.xAxis;
        xAxis.axisLineWidth = 0.6;//设置X轴线宽
        xAxis.labelPosition = .bottom
        xAxis.axisLineColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        yAxis = self.barchart.leftAxis
        yAxis.axisLineWidth = 0
        yAxis.labelPosition = .outsideChart
        yAxis.axisLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        yAxis.axisMinimum = 0
        yAxis.forceLabelsEnabled = false//不强制绘制制定数量的label
        yAxis.drawLimitLinesBehindDataEnabled = false
        self.barchart.rightAxis.enabled = false//不绘制左边轴
        
        
        //let marker : MarkerView = MarkerView.init(frame: CGRect(x:0,y:0,width:80,height:40))
        let marker : XYMarkerView = XYMarkerView.init(color: #colorLiteral(red: 0.07130721956, green: 0.03943886608, blue: 0.01833643764, alpha: 0.3821436216), font: UIFont.boldSystemFont(ofSize: 12), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0), xAxisValueFormatter: self.barchart.xAxis.valueFormatter!)
        marker.chartView = self.barchart
        self.barchart.marker = marker
        initData()
        
    }
    
    //初始化数据
    func initData() {
        gettodaydata()
        showBarChart(ydata: daydata)
        steplabel.text = "\(todaystepnum)"
    }
    //数据库获取数据
    func getalldata() {
        monthdata.removeAll()
        let result = sensordao.findAll(phone: FirstViewController.phone)
        for i in 0..<result.count{
            monthdata.append(BarChartDataEntry.init(x: Double(i+1), y: Double((result[i] as! Sensordatamodel).stepnum)))
        }
    }
    func gettodaydata(){
        daydata.removeAll()
        todaydata.removeAll()
        data_today.removeAll()
        let datestr  = dateFormatter.string(from: Date())
        let result =  sensordao.findByDate(datestr, FirstViewController.phone)
        if result != nil && result?.count != 0{
            let daodata = result![0] as! Sensordatamodel
            todaystepnum = daodata.stepnum
            data_today = [UInt8](filedao.readfile(filename: daodata.fileurl!)!)
            for i in 0..<240{
                todaydata.append(Int64(CommonUtils.byte2Day(data: [data_today[i*4+0],data_today[i*4+1],data_today[i*4+2],data_today[i*4+3]])))
            }
            for i in 0..<24{
                var ynum : Double = 0
                for j in 0...9{
                    ynum += Double(self.todaydata[10*i+j])
                }
                daydata.append(BarChartDataEntry.init(x: Double(i+1), y: ynum))
            }
        }
       
    }
   
    func showBarChart(ydata : [BarChartDataEntry]){
        var allcolor : [NSUIColor] = []
        for _ in 0..<ydata.count{
            allcolor.append(MainController.ThemeColor)
        }
        if ydata.count  != 0{
            let set : BarChartDataSet = BarChartDataSet.init(values: ydata, label: "今日")
            set.barBorderWidth = 0.1
            set.drawValuesEnabled = false
            set.barBorderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            set.colors = allcolor
            //set.colors = ChartColorTemplates.material()
            let bardata : BarChartData = BarChartData.init(dataSets: [set])
            bardata.setValueFont(UIFont.boldSystemFont(ofSize: 10))
            bardata.setValueTextColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
            self.barchart.data = bardata
            self.barchart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        }else{
            print("没有数据显示")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func segmentedaction(_ sender: Any) {
        switch self.segmented.selectedSegmentIndex {
        case 0:
            gettodaydata()
            showBarChart(ydata: daydata)
        case 1:
            getalldata()
            showBarChart(ydata: monthdata)
        case 2:
            getalldata()
             showBarChart(ydata: monthdata)
        default:
            break
        }
    }
   
    @IBAction func refreshitem(_ sender: Any) {
        let bleorders: BleOrders = BleOrders()
        let senddata = bleorders.myorder(cmd: SENDCMD.GetSportMessageCmd, data: nil)
        if BleTools.BTState == .ble_conn{
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
            toastview.showLoadingView(content: "正在加载...")
            istodaydata = true
            todayalldata.removeAll()
            
        }
    
    }
    //发送获取运动量的数据
    func sendsportcmd(){
        if BleTools.BTState == .ble_conn{
            let bleorders: BleOrders = BleOrders()
            let senddata = bleorders.myorder(cmd: SENDCMD.SportDataCmd, data: nil)
            isalldata = true
            BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
        }
    }
    
    
    var hashead : Bool = false
    var length : Int = 0
    var revdata : [UInt8] = []
    var data_length : Int = 0
    var data_year : Int32 = 0
    var data_month : Int32 = 0
    var data_day : Int32 = 0
    var data_starthh : Int32 = 0
    var data_startmm : Int32 = 0
    var data_startss : Int32 = 0
    var data_endhh : Int32 = 0
    var data_endmm : Int32 = 0
    var data_endss : Int32 = 0
    var isContinue : Bool = false
    var savedata : Data = Data()
    var savelength : Int = 0
    var isAnalysis : Bool = false

    var istodaydata : Bool = false
    var isalldata : Bool = false
    var todaydatalength : Int = 996
    var isstart : Bool = false
    var todayalldata : Data = Data()
    //revTodayStep接受到当日步数的通知
    func revTodayStep(_ notification : Notification){
        let alldata : [UInt8] = notification.object as! [UInt8]
         todayalldata.append(Data.init(bytes: alldata))
        if !self.anaytodaydata(){
            toastview.showToast(content: "解析失败！")
        }else{
            //sendsportcmd()
            toastview.showToast(content: "运动数据更新成功！")
            saveSensordata(savedata: Data.init(bytes: data_today))
            self.segmentedaction((Any).self)
        }
         toastview.clear()
    }
    
//    //接受文件
//    func revbledata(data: [UInt8]) {
//        if istodaydata {
//            if data[0] == 0x55 && data[1] == 0xAA && data[3] == 0x36{
//                isstart = true
//            }
//            if isstart{
//                todayalldata.append(Data.init(bytes: data))
//                if todayalldata.count == todaydatalength{
//                    if !self.anaytodaydata(){
//                        toastview.showToast(content: "解析失败！")
//                    }else{
//                        //sendsportcmd()
//                        toastview.showToast(content: "运动数据更新成功！")
//                        saveSensordata(savedata: Data.init(bytes: data_today))
//                        segmentedaction(Any)
//                    }
//                    isstart = false
//                    istodaydata = false
//
//                }
//                if todayalldata.count > todaydatalength{
//                    toastview.showToast(content: "解析失败！")
//                    isstart = false
//                    istodaydata = false
//
//                }
//            }
//
//        }
//        if isalldata{
//            print(data)
//            toastview.clear()
//        }
//    }

    var data_today : [UInt8] = []
    var todaydata : [Int64] = []
    //解析蓝牙当日计步的数据
    func anaytodaydata() -> Bool{
        todaydata.removeAll()
        daydata.removeAll()
        data_today.removeAll()
        var data : [UInt8] = [UInt8](todayalldata)
        
        for _ in 0..<6 {
             if data[0] == 0x55 && data[1] == 0xAA{
                data.removeSubrange(0...4)
                for i in 0..<160{
                    data_today.append(data[i])
                }
             }else{
                return false
            }
            for _ in 0..<40{
                todaydata.append(Int64(CommonUtils.byte2Day(data: [UInt8(data[0]),data[1],data[2],data[3]])))
               
                data.removeSubrange(0...3)
 
            }
            data.remove(at: 0)
        }
        self.todaystepnum = 0
        for i : Int64 in todaydata{
            self.todaystepnum = self.todaystepnum + i
            steplabel.text = "\(todaystepnum)"
        }
        
        for i in 0..<24{
            var ynum : Double = 0
            for j in 0...9{
               ynum += Double(self.todaydata[10*i+j])
            }
            daydata.append(BarChartDataEntry.init(x: Double(i+1), y: ynum))
        }
        
        return true
    }

    //保存数据
    func saveSensordata(savedata : Data) -> Bool {
    
        let datestr = dateFormatter.string(from: Date())
        //filedao.savefile(ecgdata: ecgdata, filename: filename)
        if BleTools.bindperipheral != nil{
            let filename  = filedao.createfilename(datastyle: 1, phone: FirstViewController.phone, devicename: (BleTools.bindperipheral?.name!)!, datestr: datestr)
            let data : Sensordatamodel = Sensordatamodel.init(date: datestr, fileurl: filename, isupdate: false, phone: FirstViewController.phone, deviceid: BleTools.bindperipheral?.identifier.uuidString, stepnum: Int64(todaystepnum))
            if filedao.savefile(ecgdata: savedata, filename: filename){
                let ss = sensordao.findByDate(datestr, FirstViewController.phone)
                if ss!.count>0{
                    sensordao.modify(data)
                }else{
                    sensordao.create(data)
                }
                print("数据保存成功")
                return true
            }
        }else{
            ToastView.instance.showToast(content: "蓝牙连接错误，数据未存储！")
            return false
        }
        return false
    }
    

    func sendOKStatus(){
        let bleorders : BleOrders = BleOrders()
        
        let senddata  = bleorders.myorder(cmd: SENDCMD.SendStateCmd, data: [WATCHSTATUS.STATUS_OK.rawValue])
        print(senddata)
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
    }
}
