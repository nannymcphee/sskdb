//
//  DrugSvrTimeViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 02/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import HcdDateTimePicker

extension DrugSvrTimeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let label1:UILabel = cell.viewWithTag(1) as! UILabel
        
        let time = self.items[indexPath.row]
        label1.text = time.toString("a hh:mm")
        
        label1.textColor = UIColor.black
        if self.itemChecks[indexPath.row] {
            label1.textColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let time = self.items[indexPath.row]
        if let dateTimePickerView = HcdDateTimePickerView.init(datePickerMode: DatePickerHourMinuteMode, defaultDateTime: time) {
            dateTimePickerView.clickedOkBtn = { (str) in
                self.items[indexPath.row] = (str?.toDate("HH:mm"))!
                self.loadData()
            }
            self.view.addSubview(dateTimePickerView)
            dateTimePickerView.showHcdDateTimePicker()
        }
    }
}

extension DrugSvrTimeViewController {
    // MARK: - function
    func loadData() {
        
        var drugList:[Any] = Global.drug
        
        // key
        var datas:[String:Int] = [:]
        for i in 0..<drugList.count {
            if let item = drugList[i] as? [String:Any],
                let time = item["time"] as? String {
                if let count = datas[time] {
                    datas[time] = count + 1
                } else {
                    datas[time] = 1
                }
            }
        }
        
        self.itemChecks = [Bool](repeating: false, count: self.items.count)
        for i in 0..<self.items.count {
            let date = self.items[i]
            if let count = datas[date.toString("HHmm")],
                count >= 4 {
                self.itemChecks[i] = true
            }
        }
        
        if self.itemChecks.contains(true) {
            self.buttonComplate.isEnabled = false
            "알림|||동일시간 복약은 최대 4개까지 가능합니다.".alert(self)
        } else {
            self.buttonComplate.isEnabled = true
        }
        
        tableView.reloadData()
    }
}

class DrugSvrTimeViewController: UIViewController {

    @IBOutlet weak var textFieldCount: UITextField!
    @IBOutlet weak var buttonSelectCount: UIButton!
    
    var defaultKey:Any? = nil
    var defaultTime:Any? = nil
    
    @IBOutlet weak var tableView: UITableView!
    var items:[Date] = []
    var itemChecks:[Bool] = []
    
    var resultString:String = "1"
    var dataDrugName:String?
    var dataDose:String?
    var dataUnit:String?
    var dataMark:String?
    
    @IBOutlet weak var buttonComplate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let _ = defaultKey as? String,
            let defaultTime = defaultTime as? String,
            let date = defaultTime.toDate("HHmm") {
            self.buttonComplate.isEnabled = true
            self.buttonSelectCount.isHidden = true
            self.items.append(date)
            self.textFieldCount.text = "복약 시간 수정"
        }
        self.loadData()
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionCountButton(_ sender: Any) {
        let drugSvrTimeSelectViewController = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugSvrTimeSelectViewController") as! DrugSvrTimeSelectViewController
        let vc = drugSvrTimeSelectViewController
        vc.defaultValue = self.resultString
        vc.resultCallback = { (result) in
            self.buttonComplate.isEnabled = true
            self.resultString = result
            self.textFieldCount.text = String(format: "하루 %@ 회", result)
            
            self.items.removeAll()
            var sDate = "07:00".toDate("HH:mm")
            let count:Int = Int(result)!
            for _ in 0..<count {
                sDate?.addTimeInterval(TimeInterval(60 * 60))
                self.items.append(sDate!)
            }
            self.loadData()
        }
        vc.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func actionComplateButton(_ sender: Any) {
        
        
        var drugList:[Any] = Global.drug
        
        if let defaultKey = defaultKey as? String {
            let _dic:[String:Any] = [
                "key": defaultKey,
                "time": self.items[0].toString("HHmm"),
                "drugName": self.dataDrugName as Any,
                "dose": self.dataDose as Any,
                "unit": self.dataUnit as Any,
                "mark": self.dataMark as Any
            ]
            for i in 0..<drugList.count {
                if let item = drugList[i] as? [String:Any],
                    let key = item["key"] as? String,
                    key == defaultKey {
                    drugList[i] = _dic
                }
            }
        } else {
            for i in 0..<self.items.count {
                let time = self.items[i]
                let _dic:[String:Any] = [
                    "key": Date().toString("yyyyMMddHHmmssSSS") + time.toString("HHmm"),
                    "time": time.toString("HHmm"),
                    "drugName": self.dataDrugName as Any,
                    "dose": self.dataDose as Any,
                    "unit": self.dataUnit as Any,
                    "mark": self.dataMark as Any
                ]
                
                drugList.append(_dic)
            }
        }
        
        Global.drug = drugList

        // 리스트 화면으로 돌아가기.
        for vc in self.navigationController!.viewControllers {
            if vc.isKind(of: DrugListViewController.self) {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
