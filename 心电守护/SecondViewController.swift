//
//  SecondViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/14.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

var diagdao =  DiagnosisMsgDao.sharedInstance
var ecgmsgdao: ECGmsgDao = ECGmsgDao.sharedInstance
class SecondViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var calenderbackView: UIView!
    @IBOutlet weak var calenderheaderView: UIStackView!
    @IBOutlet weak var calendarheight: NSLayoutConstraint!
    @IBOutlet weak var timetitlelabel: UILabel!
    @IBOutlet weak var calendarview: UICollectionView!
    @IBOutlet weak var ecgtableview: UITableView!
    @IBOutlet weak var ecgmsgview: UIView!
    var calendardatasources : CalendarDataSources!
    var ecgdatadao: ECGDataDao = ECGDataDao.sharedInstance
    var year : Int = 0
    var month : Int = 0
    var monthday  : Int = 0
    var weekday : Int!
    var currentday : Int!
    var currenyear : Int!
    var currenmonth : Int!
    var ecgdatalist : NSMutableArray?
    let dateformatter : DateFormatter = DateFormatter()
    var phone : String!
    var screenSize : CGSize!
    var calendarsection = 5
    var itemheight : CGFloat = 35
    var calendardata : Array<Int> = [Int]()
    var startloc : CGPoint!
    var endloc : CGPoint!
    var allindexpath : [IndexPath] = [IndexPath]()
    var beforeindex : IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificaton()
        initView()
        //初始化时间
        initDate()
    }
    
    //初始化界面
    func initView(){
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        screenSize  = UIScreen.main.bounds.size;

        let userdefaults : UserDefaults = .standard
        phone = userdefaults.string(forKey: "phone")
        
        calenderbackView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calenderbackView.layer.borderWidth = 0.5
        calenderbackView.layer.cornerRadius = 4
        calenderbackView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        calenderbackView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
//        calenderbackView.layer.shadowOpacity = 0.6
//        calenderbackView.layer.shadowRadius = 5
//        calenderbackView.clipsToBounds = false
//        calenderbackView.layer.masksToBounds =  false
        calenderbackView.backgroundColor = MainController.ThemeColor
        
        ecgmsgview.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        ecgmsgview.layer.borderWidth = 0.5
        ecgmsgview.layer.cornerRadius = 4
        ecgmsgview.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        ecgmsgview.layer.shadowOffset = CGSize.init(width: 1, height: 1)
//        ecgmsgview.layer.shadowOpacity = 0.6
//        ecgmsgview.layer.shadowRadius = 5
//        ecgmsgview.clipsToBounds = false
//        ecgmsgview.layer.masksToBounds =  false
        
        //重新设置iPhone 6/6s/7/7s/Plus
        if screenSize.height>568{
            itemheight = 44
        }else{
            itemheight = 37
        }
        //加载流布局
        calendarview.setCollectionViewLayout(calendarlayout.init(itemheight: itemheight), animated: true)
    }
    
    //初始化通知注册
    func initNotificaton(){
        NotificationCenter.default.addObserver(self, selector: #selector(closeAction), name: Notification.Name("closeapp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reClendarData), name: Notification.Name("ECGmsg"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reClendarData), name: Notification.Name("DiagnosisMsg"), object: nil)
    }
    
    //初始化date信息
    func initDate(){
        let date : Date  = Date()
        let calendar : Calendar = Calendar.current
        currenyear = calendar.component(.year, from: date)
        currenmonth = calendar.component(.month, from: date)
        currentday = calendar.component(.day, from: date)
        year = currenyear
        month = currenmonth
        calendardatasources = CalendarDataSources.init(year: self.year, month: self.month)
        monthday = calendardatasources.getMonthDays()
        weekday = calendardatasources.getWeekDaywithDate()
        createdata()
        timetitlelabel.text = "\(year)年\(month)月"
    }
    
    //初始化日历高度和大小
    func initCalendarview(){
    
        //计算日历的高度
         calendarheight.constant = 25+CGFloat(calendarsection)*itemheight
    }
    
    //更新日历
    func reClendarData(){
        let userdefaults : UserDefaults = .standard
        phone = userdefaults.string(forKey: "phone")
        calendarview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func closeAction(){
        removeNotification()
        self.dismiss(animated: true, completion: nil)
    }
    //左翻
    @IBAction func leftbtn(_ sender: Any) {
        month += -1
        if  month < 1{
            month = 12
            year += -1
        }
        timetitlelabel.text = "\(year)年\(month)月"
        calendardatasources = CalendarDataSources.init(year: self.year, month: self.month)
        monthday = calendardatasources.getMonthDays()
        weekday = calendardatasources.getWeekDaywithDate()
        beforeindex = nil
        createdata()
        ecgdatalist = []
        ecgtableview.reloadData()
        calendarview.reloadData()
         allindexpath.removeAll()
        
    }
    //滑动手势实现对日历的翻动
    @IBAction func calendarpan(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began{
            startloc = sender.location(in: sender.view!)
        }
        if sender.state == .ended || sender.state == .failed{
            endloc = sender.location(in: sender.view!)
            if (startloc.x - endloc.x) < -50{
                leftbtn(self)
            }
            if (startloc.x - endloc.x) > 50{
                
                rightbtn(self)
            }

        }
    }
    //右翻
    @IBAction func rightbtn(_ sender: Any) {
        month += 1
        if  month > 12{
            month = 1
            year += 1
        }
        
        timetitlelabel.text = "\(year)年\(month)月"
        beforeindex = nil
        calendardatasources = CalendarDataSources.init(year: self.year, month: self.month)
        monthday = calendardatasources.getMonthDays()
        weekday = calendardatasources.getWeekDaywithDate()
        createdata()
        ecgdatalist = []
        ecgtableview.reloadData()
        calendarview.reloadData()
        allindexpath.removeAll()
    }
    
    //生成日历的大小
    func createdata(){
        calendardata.removeAll()
        var n = 0
        if monthday + weekday <= 36{
            n = 36
        }else{
            n = 43
        }
        for i in 1..<n{
            if i>=weekday && i < monthday + weekday {
                self.calendardata.append(i-weekday+1)
            }else{
                self.calendardata.append(0)
            }
        }
        //单元格的节数
        calendarsection = calendardata.count/7
        initCalendarview()
    }
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarcell", for: indexPath) as! CalendarCell
        //计算events集合下标索引
        allindexpath.append(indexPath)
        let idx = indexPath.section * 7 + indexPath.row;
        
        if calendardata[idx] > 0{
            dateformatter.dateFormat = "yyyy-MM-dd"
            cell.celllabel.isHidden = true
            cell.date.setTitle("\(calendardata[idx])", for: .normal)
            cell.date.setBackgroundImage(nil, for: .normal)
            cell.date.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            cell.redsign.isHidden = true
            cell.celllabel.isHidden = true
            cell.celllabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            iscellSelected(false,  cell)
            //当前日历日期
            let data : CalendarDataSources = CalendarDataSources.init(year: year, month: month, day: self.calendardata[idx])
            let datestr = dateformatter.string(from: data.toDate())
            let ecgmsg  = ecgmsgdao.findByDate(datestr, phone)
            if ecgmsg != nil{
                cell.celllabel.isHidden = false
                cell.celllabel.text = NSString.init(format: "%d条数据", (ecgmsg?.datanum)!) as String
                cell.date.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                cell.redsign.isHidden = false
            }
            
            if currentday <= monthday && idx == currentday+weekday-2{
               // cell.date.setBackgroundImage(UIImage.init(named: "日历背景.png"), for: .normal)
                
                iscellSelected(true,  cell)
                
                cell.date.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                cell.celllabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                beforeindex = indexPath
                ecgdatalist = ecgdatadao.findByDate(datestr, phone)
                if ecgdatalist != nil{
                    ecgtableview.isHidden = false
                    ecgtableview.reloadData()
                }else{
                    ecgtableview.isHidden = true
                }
            }
            
        }else{
            cell.celllabel.isHidden = true
             cell.date.setBackgroundImage(nil, for: .normal)
            cell.celllabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.date.setTitle(" ", for: .normal)
            cell.redsign.isHidden = true
            iscellSelected(false,  cell)
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let idx = indexPath.section * 7 + indexPath.row
        if idx+1>=weekday && idx+1<weekday+monthday{
            if beforeindex != nil{
                let beforecell  =  collectionView.cellForItem(at: beforeindex) as! CalendarCell
                beforecell.date.setBackgroundImage(nil, for: .normal)
                beforecell.celllabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                beforecell.date.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                iscellSelected(false,  beforecell)

            }
             dateformatter.dateFormat = "yyyy-MM-dd"
            let data : CalendarDataSources = CalendarDataSources.init(year: year, month: month, day: self.calendardata[idx])
            let datestr = dateformatter.string(from: data.toDate())
            ecgdatalist = ecgdatadao.findByDate(datestr, phone)
            if ecgdatalist != nil{
                ecgtableview.isHidden = false
                ecgtableview.reloadData()
            }else{
                ecgtableview.isHidden = true
            }

            let cell  =  collectionView.cellForItem(at: indexPath) as! CalendarCell
            //cell.date.setBackgroundImage(UIImage.init(named: "日历背景.png"), for: .normal)
            iscellSelected(true,  cell)
             cell.celllabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.date.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            beforeindex = indexPath
           
        }
    }
    //cell的状态
    func iscellSelected(_ isselected: Bool,_ cell: CalendarCell){
        if isselected{
            
            cell.date.layer.cornerRadius = 17.5
            cell.date.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.date.layer.backgroundColor = #colorLiteral(red: 0, green: 0.6479217289, blue: 0.9158669099, alpha: 1)
            
        }else{
            cell.date.layer.cornerRadius = 0
            cell.date.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.date.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.date.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calendardata.count/7
    }
    
    //tableview的回调
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ecgdatalist == nil{
            return 0
        }else{
            return (ecgdatalist?.count)!
        }
       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dateformatter.dateFormat = "HH:mm:ss"
        let  cell  = tableView.dequeueReusableCell(withIdentifier: "ecgdatacell", for: indexPath) as! ECGTableViewCell
        let data = ecgdatalist?[indexPath.row] as! ECGdata
        cell.maclabel.text = data.deviceid
        cell.devicename.text = data.devicename
        cell.startdatelabel.text = dateformatter.string(from: data.startdate! as Date)
        cell.enddatelabel.text = dateformatter.string(from: data.enddate! as Date)
        let diagdata = diagdao.findBydataId(data.dataId!, LoadViewController.USERNAME)
        if diagdata != nil && !(diagdata?.isread)!{
            cell.devicename.textColor = #colorLiteral(red: 1, green: 0.224928888, blue: 0, alpha: 1)
            cell.startdatelabel.textColor = #colorLiteral(red: 1, green: 0.224928888, blue: 0, alpha: 1)
            cell.enddatelabel.textColor = #colorLiteral(red: 1, green: 0.224928888, blue: 0, alpha: 1)
        }else{
             cell.devicename.textColor = #colorLiteral(red: 0, green: 0.6479217289, blue: 0.9158669099, alpha: 1)
            cell.startdatelabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.enddatelabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showecg"{
            let indexpath  = self.ecgtableview.indexPathForSelectedRow as! IndexPath
            let data = ecgdatalist?[indexpath.row] as! ECGdata
            let ecgvc = segue.destination as! ECGDataViewController
            dateformatter.dateFormat = "hh:mm:ss"
            ecgvc.datestr = data.date!
            ecgvc.startdate = dateformatter.string(from: (data.startdate as! Date))
            ecgvc.enddate = dateformatter.string(from: (data.enddate as! Date))
            ecgvc.filepath = data.fileurl!
            ecgvc.samplerate = data.samplerate!
            if data.isupdate{
                ecgvc.dataId = data.dataId!
            }
        }

    }
    
    func removeNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
}

