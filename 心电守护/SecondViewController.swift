//
//  SecondViewController.swift
//  心电守护
//
//  Created by 孔庆达 on 2017/8/14.
//  Copyright © 2017年 qingda kong. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var calendarheight: NSLayoutConstraint!
    @IBOutlet weak var timetitlelabel: UILabel!
    @IBOutlet weak var calendarview: UICollectionView!
    @IBOutlet weak var ecgtableview: UITableView!
    var calendardatasources : CalendarDataSources!
    var year : Int = 0
    var month : Int = 0
    var monthday  : Int = 0
    var weekday : Int!
    var currentday : Int!
    var currenyear : Int!
    var currenmonth : Int!
    var ecgdatalist : NSMutableArray?
    let dateformatter : DateFormatter = DateFormatter()
    var ecgdatadao: ECGDataDao = ECGDataDao()
    var ecgmsgdao: ECGmsgDao = ECGmsgDao()
    var phone : String!
    
    
    var calendardata : Array<Int> = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black;
        self.navigationController?.navigationBar.barTintColor = MainController.ThemeColor
        self.tabBarController?.tabBar.selectedImageTintColor = MainController.ThemeColor
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //初始化时间
        initDate()
        
        timetitlelabel.text = "\(year)年\(month)月"
        NotificationCenter.default.addObserver(self, selector: #selector(reClendarData), name: Notification.Name("ECGmsg"), object: nil)
        let userdefaults : UserDefaults = .standard
        phone = userdefaults.string(forKey: "phone")
        ecgdatadao = ECGDataDao.sharedInstance
        ecgmsgdao = ECGmsgDao.sharedInstance
        // 2.设置每个单元格的尺寸
        let screenSize  = UIScreen.main.bounds.size;
        calendarheight.constant = ((screenSize.height-CGFloat(100))/CGFloat(2))-CGFloat(40)
        
    
        // 1.创建流式布局布局
        let layout = UICollectionViewFlowLayout()
        // 4.设置单元格之间的间距
        layout.minimumInteritemSpacing = 0
        if calendarheight.constant/CGFloat(5) > CGFloat(200){
            layout.itemSize = CGSize(width: (screenSize.width-10)/7, height: calendarheight.constant/CGFloat(5))
        }else{
            layout.itemSize = CGSize(width: (screenSize.width-10)/7, height: 200)
        }
        layout.itemSize = CGSize(width: (screenSize.width-10)/7, height: calendarheight.constant/CGFloat(5))
        // 3.设置整个collectionView的内边距
        //layout.sectionInset = UIEdgeInsetsMake(15, 15, 30, 15)
        
         //重新设置iPhone 6/6s/7/7s/Plus
         if (screenSize.height > 568) {
            layout.itemSize = CGSize(width: (screenSize.width-10)/7, height: calendarheight.constant/CGFloat(5))
            //layout.sectionInset = UIEdgeInsetsMake(15, 15, 20, 15)
        }
        
        
        calendarview.setCollectionViewLayout(layout, animated: false)
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
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
        //calendarview.reloadData()
        //calendarview.reloadItems(at: allindexpath)
        createdata()
        calendarview.reloadData()
         allindexpath.removeAll()
        
    }
    var startloc : CGPoint!
    var endloc : CGPoint!
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
        //calendarview.deleteSections([0,1,2,3,4])
        //calendarview.reloadSections([0,1,2,3,4])
       // calendarview.reloadItems(at: allindexpath)
        createdata()
        calendarview.reloadData()
        allindexpath.removeAll()
    }
    
    func createdata(){
        calendardata.removeAll()
        for i in 1...35{
            if i>=weekday && i < monthday + weekday {
                self.calendardata.append(i-weekday+1)
            }else{
                self.calendardata.append(0)
            }
        }
    }
    
    var allindexpath : [IndexPath] = [IndexPath]()
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
            cell.redsign.isHidden = true
            cell.celllabel.isHidden = true
            //当前日历日期
            let data : CalendarDataSources = CalendarDataSources.init(year: year, month: month, day: self.calendardata[idx])
            let datestr = dateformatter.string(from: data.toDate())
            let ecgmsg  = ecgmsgdao.findByDate(datestr, phone)
            if ecgmsg != nil{
                cell.celllabel.isHidden = false
                cell.celllabel.text = NSString.init(format: "%d条数据", (ecgmsg?.datanum)!) as String
                cell.redsign.isHidden = false
            }
            
            if currentday < monthday && idx == currentday+weekday-2{
                cell.date.setBackgroundImage(UIImage.init(named: "日历-selector.png"), for: .normal)
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
            cell.date.setTitle(" ", for: .normal)
            cell.redsign.isHidden = true
            
        }
        
        return cell
        
    }
    var beforeindex : IndexPath!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let idx = indexPath.section * 7 + indexPath.row
        if idx+1>=weekday && idx+1<weekday+monthday{
            if beforeindex != nil{
                let beforecell  =  collectionView.cellForItem(at: beforeindex) as! CalendarCell
                beforecell.date.setBackgroundImage(nil, for: .normal)

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
            cell.date.setBackgroundImage(UIImage.init(named: "日历-selector.png"), for: .normal)
            beforeindex = indexPath
           
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
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
        cell.devicename.text = data.devicename
        cell.startdatelabel.text = dateformatter.string(from: data.startdate! as Date)
        cell.enddatelabel.text = dateformatter.string(from: data.enddate! as Date)
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
        }

    }
    
}

