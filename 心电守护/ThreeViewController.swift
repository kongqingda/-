//
//  ThreeViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/15.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit
import Charts

let sensordao : SensorDataDao = SensorDataDao.sharedInstance
class ThreeViewController: UIViewController,ChartViewDelegate{
    
    @IBOutlet weak var progresslabel: UILabel!
    @IBOutlet weak var progressview: UIProgressView!
    @IBOutlet weak var updatedataview: UIView!
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
    var daydata : Array<BarChartDataEntry> = []
    var weekdata : Array<BarChartDataEntry> = []
    var monthdata : Array<BarChartDataEntry> = []
    var todaystepnum : Int64 = 0
    var dateFormatter : DateFormatter = DateFormatter()
    let filedao : FiledocmDao =  FiledocmDao.init()
    
     var bardata : BarChartData = BarChartData.init()
    var set : BarChartDataSet = BarChartDataSet.init()
    
    var savedata : Data = Data()
    var isalldata : Bool = false
    var todaydatalength : Int = 996
    var isstart : Bool = false
    var todayalldata : Data = Data()
    var data_today : [UInt8] = []
    var todaydata : [Int64] = []
    
    var Sportdata : Data = Data()
    var baonum : Int = 0
    var beforebaonum : Int = 0
    var historydatanum = 0 //历史数据的总天数
    var data_year: Int32 = 0
    var data_month: Int32 = 0
    var data_day : Int32 = 0
    var sn : Int32 = 0
    
    var historydata : [Int64] = []
    var data_history : [UInt8] = []
    var calendardataSources : CalendarDataSources!
    var sensorshowdata : SensorShowData = SensorShowData.init()
    var marker : XYMarkerView!
    var waittimer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor

        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        BleDataAnalysis.shareInstance

        dateformatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date : Date  = Date()
        timetitlelabel.text = dateformatter.string(from: date)
        initNotification()
        initchartview()
       updatedataview.isHidden = true
        
    }
    //初始化barchartview
    func initchartview() {
    
        updatedataview.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        updatedataview.layer.borderWidth = 0.5
        updatedataview.layer.cornerRadius = 4
        updatedataview.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        updatedataview.layer.shadowOffset = CGSize.init(width: 5, height: 1)
        updatedataview.layer.shadowOpacity = 0.6
        updatedataview.layer.shadowRadius = 5
        updatedataview.clipsToBounds = false
        updatedataview.layer.masksToBounds =  false
        
        self.barchart.delegate = self
        self.barchart.noDataText = "没有数据显示，请刷新试试"
        self.barchart.drawValueAboveBarEnabled = true//数值显示在柱形的上面还是下面
        self.barchart.drawBarShadowEnabled = false;//是否绘制柱形的阴影背景
        self.barchart.scaleYEnabled = false;//取消Y轴缩放
        self.barchart.scaleXEnabled = false //取消X轴缩放
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
        self.barchart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        
        let l : Legend = self.barchart.legend
        l.enabled = false
        
        self.barchart.chartDescription?.text = "计步信息"
        
        xAxis = self.barchart.xAxis;
        xAxis.axisLineWidth = 0.6;//设置X轴线宽
        xAxis.labelPosition = .bottom
        xAxis.axisLineColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        xAxis.drawGridLinesEnabled = false;//不绘制网格线
        //xAxis.gridColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        yAxis = self.barchart.leftAxis
        yAxis.axisLineWidth = 0
        yAxis.labelPosition = .outsideChart
        yAxis.axisLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        yAxis.axisMinimum = 0
        yAxis.forceLabelsEnabled = true//不强制绘制制定数量的label
        yAxis.drawLimitLinesBehindDataEnabled = true
        self.barchart.rightAxis.enabled = false//不绘制左边轴
        
        //let marker : MarkerView = MarkerView.init(frame: CGRect(x:0,y:0,width:80,height:40))
        
        bardata.setValueFont(UIFont.boldSystemFont(ofSize: 12))
        bardata.setValueTextColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        
        initData()
        
    }
    //注册通知
    func initNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(revTodayStep(_:)), name: Notification.Name("gettodaystep"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(revHistorySportData(_:)), name: Notification.Name("gethistorysportdata"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endupdate), name: Notification.Name("endupdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeAction), name: Notification.Name("closeapp"), object: nil)
    }
    
    
    //初始化数据
    func initData() {
        let date : Date = Date()
        let calendar : Calendar = Calendar.init(identifier: .gregorian)     //指定日历的算法
        let year : Int = calendar.component(.year, from: date)
        let month : Int = calendar.component(.month, from: date)
        let day : Int = calendar.component(.day, from: date)
        calendardataSources = CalendarDataSources.init(year: year, month: month, day: day)
        (daydata,todaystepnum) = sensorshowdata.gettodaydata()
        showBarChart(ydata: daydata)
        steplabel.text = "\(todaystepnum)"
    }
   
    //显示柱状图
    func showBarChart(ydata : [BarChartDataEntry]){
       
        var allcolor : [NSUIColor] = []
        for _ in 0..<ydata.count{
            allcolor.append(MainController.ThemeColor)
        }
        if ydata.count  == 0{
            print("没有数据显示")
            return
        }
        set = BarChartDataSet.init(values: ydata, label: "时间")
        set.drawValuesEnabled = false
        set.barShadowColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
       // set.barBorderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //set.colors = allcolor
        set.colors = ChartColorTemplates.material()
        var dateArray : [String] = []
        switch ydata.count {
        case 30:
            dateArray = calendardataSources.getNearMonthDate()
        case 24:
            dateArray = calendardataSources.getTodayDate()
        case 7:
            dateArray = calendardataSources.getNearWeekDate()
        default:
            break
        }
        
        bardata = BarChartData.init(dataSets: [set])
        yAxis.axisMaximum = set.yMax + set.yMax/5
        //xAxis.axisMaximum = set.xMax
        xAxis.valueFormatter = xvalueFormatter.init(xvalue: dateArray)
        marker = XYMarkerView.init(color: #colorLiteral(red: 0.07130721956, green: 0.03943886608, blue: 0.01833643764, alpha: 0.3821436216), font: UIFont.boldSystemFont(ofSize: 12), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0), xAxisValueFormatter: xAxis.valueFormatter! as! xvalueFormatter)
        marker.chartView = self.barchart
        self.barchart.marker = marker
        self.barchart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        self.barchart.data = bardata
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   //时间选择的响应
    @IBAction func segmentedaction(_ sender: Any) {
        let date : Date = Date()
        let calendar : Calendar = Calendar.init(identifier: .gregorian)     //指定日历的算法
        let year : Int = calendar.component(.year, from: date)
        let month : Int = calendar.component(.month, from: date)
        let day : Int = calendar.component(.day, from: date)
        calendardataSources = CalendarDataSources.init(year: year, month: month, day: day)
        sensorshowdata = SensorShowData.init()
        switch self.segmented.selectedSegmentIndex {
        case 0:
            (daydata,todaystepnum) = sensorshowdata.gettodaydata()
            showBarChart(ydata: daydata)
            
        case 1:
            showBarChart(ydata: sensorshowdata.getweekdata())
        case 2:

             showBarChart(ydata: sensorshowdata.getmonthdata())
        default:
            break
        }
    }
   //刷新事件
    @IBAction func refreshitem(_ sender: Any) {
        if BleTools.BTState == .ble_conn{
            //toastview.showLoadingView(content: "正在加载...")
            MainController.isSendable = false
            self.perform(#selector(sendTodayCmd), with: nil, afterDelay: 0.2)
            
        }
    
    }
    func closeAction(){
        removeNotification()
        self.dismiss(animated: true, completion: nil)
    }
    //revTodayStep接受到当日步数的通知
    func revTodayStep(_ notification : Notification){
        let alldata : [UInt8] = notification.object as! [UInt8]
         todayalldata.append(Data.init(bytes: alldata))
        if !self.anaytodaydata(){
            toastview.showToast(content: "解析失败！")
        }else{
            //sendsportcmd()
            let datestr = dateFormatter.string(from: Date())
            saveSensordata(istoday: true, sportstepnum: todaystepnum, savedata: Data.init(bytes: data_today), datestr: datestr)
            self.segmentedaction((Any).self)
        }
        
        Sportdata.removeAll()
        baonum = 0
        historydatanum = 0
        sn = 0
        self.perform(#selector(sendsportcmd), with: nil, afterDelay: 0.2)
    }
    
    
    //接受到历史运动数据
    func revHistorySportData(_ notification: Notification){
        if waittimer == nil{
            waittimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(closeupdateview), userInfo: nil, repeats: true)
        }
         self.sendOKStatus()
        var alldata : [UInt8] = notification.object as! [UInt8]
        if alldata.count<20{
            return
        }
        baonum += 1
        let newsn = CommonUtils.byte2Year(data: CommonUtils.copyofRange(data: alldata, from: 4, to: 7))
        if sn == 0{
            sn = newsn-1
        }
        
        if newsn == sn+1{
            sn = newsn
        }else if newsn == sn{
            hoitoryerror()
            return
        }
         updatedataview.isHidden = false
        if baonum == 1{
            historydatanum = Int(alldata[9])
            progressview.progress = 1.0
        }else{
            let num =  (baonum-1)%5
            switch num{
            case 1:
                //数据年月日
                data_year = CommonUtils.byte2Year(data: CommonUtils.copyofRange(data: alldata, from: 9, to: 12))
                data_month = CommonUtils.byte2Month(data: CommonUtils.copyofRange(data: alldata, from: 13, to: 16))
                data_day = CommonUtils.byte2Day(data: CommonUtils.copyofRange(data: alldata, from: 17, to: 20))
            case 2,3,4:
                if Int(alldata[9]) == num-1{
                    alldata.removeSubrange(0..<10)
                    alldata.removeLast()
                    if alldata.count == 240{
                        if Sportdata.count == 240*(num-2){
                            Sportdata.append(Data.init(bytes: alldata))
                        }
                    }else{
                        hoitoryerror()
                        return
                    }
                    
                }else{
                    hoitoryerror()
                    return
                }
            case 0:
                if Int(alldata[9]) == 4{
                    alldata.removeSubrange(0..<10)
                    alldata.removeLast()
                    if alldata.count == 240{
                        if Sportdata.count == 240*3{
                            Sportdata.append(Data.init(bytes: alldata))
                            print([UInt8](Sportdata))
                        }
                    }else{
                        hoitoryerror()
                        return
                    }
                    
                }else{
                   hoitoryerror()
                   return
                }
                if Sportdata.count == 960{
                    anaysishistorydata(Sportdata, data_year, data_month, data_day)
                    Sportdata.removeAll()
                }
            default:
                break
            }
            
            self.progressview.progress = Float(baonum/((historydatanum*5)+1))
            progresslabel.text = "\(100*Float(baonum/((historydatanum*5)+1)))%"
        }
       
        
    }
    
    func hoitoryerror(){
        baonum -= 1
        sn -= 1
        ToastView.instance.showToast(content: "数据传输错误！")
        self.perform(#selector(sendOKStatus), with: nil, afterDelay: 0)
    }
    
    func closeupdateview(){
        if !updatedataview.isHidden{
            if baonum != 0{
                if baonum == beforebaonum{
                    updatedataview.isHidden = true
                    waittimer.invalidate()
                    waittimer = nil
                }
            }
            beforebaonum = baonum
        }
    }
    
    //解析历史数据
    func anaysishistorydata(_ daydata: Data,_ year:Int32,_ month: Int32,_ day: Int32) {
        var sportstep : Int16 = 0
        var data : [UInt8] = [UInt8](daydata)
        for i in 0..<240{
            //let j = CommonUtils.byte2Day(data: [data[4*i+0],data[4*i+1],data[4*i+2],data[4*i+3]])
            let j = CommonUtils.byte2int16(data: [data[4*i+2],data[4*i+3]])
            sportstep = sportstep + j
        }
        let datestr : String = String.init(format: "%d-%02ld-%02ld", year,month,day)
        if saveSensordata(istoday: false, sportstepnum: Int64(sportstep), savedata: daydata, datestr: datestr){
            //self.perform(#selector(sendsportcmd), with: nil, afterDelay: 0.1)
             self.perform(#selector(sendOKStatus), with: nil, afterDelay: 0)
        }
        
    }
    
    
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
                todaydata.append(Int64(CommonUtils.byte2Day(data: [data[0],data[1],data[2],data[3]])))
               
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
    func saveSensordata(istoday: Bool,sportstepnum: Int64, savedata : Data,datestr: String) -> Bool {
        //filedao.savefile(ecgdata: ecgdata, filename: filename)
        var filename = "无文件"
        if BleTools.bindperipheral != nil{
            if istoday{
                filename  = filedao.createfilename(datastyle: 1, phone: FirstViewController.phone, devicename: (BleTools.bindperipheral?.name!)!, datestr: "today")
            }
            let data : Sensordatamodel = Sensordatamodel.init(date: datestr, fileurl: filename, isupdate: false, phone: FirstViewController.phone, deviceid: BleTools.BLEMAC, stepnum: sportstepnum)
            if istoday {
                if !filedao.savefile(ecgdata: savedata, filename: filename){
                    return false
                }
            }
            let ss = sensordao.findByDate(datestr, FirstViewController.phone)
            if ss != nil{
                sensordao.modify(data)
            }else{
                sensordao.create(data)
            }
            print("数据保存成功")
            return true
           
        }else{
            ToastView.instance.showToast(content: "蓝牙连接错误，数据未存储！")
            return false
        }
        return false
    }
    
    func endupdate(){
        updatedataview.isHidden = true
        segmentedaction((Any).self)
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
    //发送OK状态
    func sendOKStatus(){
        let bleorders : BleOrders = BleOrders()
        let senddata  = bleorders.myorder(cmd: SENDCMD.SendStateCmd, data: [WATCHSTATUS.STATUS_OK.rawValue])
        print(senddata)
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
    }
    //发送获取当天运动量的数据
    func sendTodayCmd(){
        let bleorders: BleOrders = BleOrders()
        let senddata = bleorders.myorder(cmd: SENDCMD.GetSportMessageCmd, data: nil)
        BleTools.sharedInstance.APPsendData(data: Data.init(bytes: senddata))
        todayalldata.removeAll()
    }
    
    func removeNotification(){
       NotificationCenter.default.removeObserver(self)
    }
}
