//
//  DrugTodayListViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 10/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

extension DrugTodayListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let label1:UILabel = cell.viewWithTag(1) as! UILabel
        let view100:UIView = cell.viewWithTag(100)!
        let view200:UIView = cell.viewWithTag(200)!
        let view300:UIView = cell.viewWithTag(300)!
        let view400:UIView = cell.viewWithTag(400)!
        
        view100.visibility = .visible
        view200.visibility = .visible
        view300.visibility = .visible
        view400.visibility = .visible
        
        let time = self.items[indexPath.row]
        label1.text = time.toDate("HHmm")?.toString("HH:mm")
        
        guard let row = self.datas[time] as? [Any] else {
            return cell
        }
        
        if row.count == 4 {
            
        } else if row.count == 3 {
            view400.visibility = .gone
        } else if row.count == 2 {
            view300.visibility = .gone
            view400.visibility = .gone
        } else if row.count == 1 {
            view200.visibility = .gone
            view300.visibility = .gone
            view400.visibility = .gone
        }
        
        let viewArray = [view100, view200, view300, view400]
        for i in 0..<row.count {
            if i > 3 {
                continue
            }
            if let item = row[i] as? [String:Any] {
                let view = viewArray[i]
                
                let imageView1 = view.viewWithTag(1) as! UIImageView
                let label2 = view.viewWithTag(2) as! UILabel
                
                let drugName:String = item["drugName"] as! String
                let dose:String = item["dose"] as! String
                let unit:String = item["unit"] as! String
                let mark:String = item["mark"] as! String
                
                imageView1.image = UIImage.init(named: mark)?.scale(scale: 0.6)
                label2.text = String(format: "%@ %@%@", drugName, dose, unit)
            }
        }
        
        
        if let view:UIView = cell.viewWithTag(6) {
            view.backgroundColor = UIColor.init(hexString: "F9FAFB", andAlpha: 0.2)
        }
        if let button:UIButton = cell.viewWithTag(4) as? UIButton {
            button.object = nil
            button.addTarget(self, action: #selector(buttonDetailClicked(sender:)), for: .touchUpInside)
            if let userInfoTime = self.userInfo!["time"] as? String,
                userInfoTime == time.toDate("HHmm")?.toString("HHmm") {
                if let view:UIView = cell.viewWithTag(6) {
                    view.backgroundColor = UIColor.init(hexString: "7796E7", andAlpha: 0.2)
                }
                button.object = "delete"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func buttonDetailClicked(sender:UIButton) {
        if let _val = sender.object as? String,
            _val == "delete" {
            debugPrint(Global.todayDrugList)
            var todayDrug:[String:Any] = [
                "date": Date().toString("yyyyMMdd"),
                "list": []
            ]
            if var _drug = Global.todayDrugList as? [String:Any] {
                if let date = _drug["date"] as? String,
                    date == Date().toString("yyyyMMdd") {
                    todayDrug = _drug
                }
            }
            
            debugPrint(todayDrug)
            
            if var list = todayDrug["list"] as? [Any],
                let userInfoTime = self.userInfo!["time"] as? String {
                list.append(userInfoTime)
                todayDrug["list"] = list
            }
            Global.todayDrugList = todayDrug
            
            loadData()
        } else {
            "복용시간이 아닙니다.".alert(self)
        }
    }
}
class DrugTodayListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var items:[String] = []
    var datas:[String:Any] = [:]
    
    var userInfo:[AnyHashable:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        debugPrint("==========")
        debugPrint(userInfo)
        debugPrint(Global.todayDrugList)
        
        if let _drug = Global.todayDrugList as? [String:Any], let date = _drug["date"] as? String, date == Date().toString("yyyyMMdd") {
        } else {
           Global.todayDrugList = [
                "date": Date().toString("yyyyMMdd"),
                "list": []
            ]
        }
        
        loadData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadData() {
        var drugList:[Any] = Global.drug
        
        self.datas.removeAll()
        self.items.removeAll()
        
        // key
        for i in 0..<drugList.count {
            if let item = drugList[i] as? [String:Any], let time = item["time"] as? String {
                if var _drug = Global.todayDrugList as? [String:Any] {
                    if let date = _drug["date"] as? String, date == Date().toString("yyyyMMdd") {
                        if let list = _drug["list"] as? [String], list.contains(time) {
                        } else {
                            self.datas[time] = []
                        }
                    }
                }
            }
        }
        // data set
        for i in 0..<drugList.count {
            if let item = drugList[i] as? [String:Any],
                let time = item["time"] as? String {
                var arr = self.datas[time] as? [Any]
                arr?.append(item)
                self.datas[time] = arr
            }
        }
        
        self.items = self.datas.keys.sorted { (v1, v2) -> Bool in
            return v1 < v2
        }
        
        self.tableView.reloadData()
        
        
        
        if self.items.count == 0 {
            let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugComplateViewController") as! DrugComplateViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let viewControllers = [
                    self.navigationController?.viewControllers.first!,
                    self.navigationController?.viewControllers.last!
                ]
                self.navigationController?.viewControllers = viewControllers as! [UIViewController]
            }
            return
        }
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
