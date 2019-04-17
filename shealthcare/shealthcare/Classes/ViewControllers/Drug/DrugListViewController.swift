//
//  DrugListViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 21/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

extension DrugListViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
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
                
                if let button3:UIButton = view.viewWithTag(3) as? UIButton {
                    button3.object = item
                    button3.addTarget(self, action: #selector(buttonDetailClicked(sender:)), for: .touchUpInside)
                }
                
                if let button99:UIButton = view.viewWithTag(99) as? UIButton {
                    button99.object = item
                    button99.addTarget(self, action: #selector(buttonDeleteClicked(sender:)), for: .touchUpInside)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func buttonDetailClicked(sender:UIButton) {
        guard let selectedItem = sender.object as? [String:Any] else {
            return
        }
        
        let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugAddViewController") as! DrugAddViewController
        vc.defaultItem = selectedItem
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonDeleteClicked(sender:UIButton) {
        guard let selectedItem = sender.object as? [String:Any] else {
            return
        }
        
        guard let key = selectedItem["key"] as? String else {
            return
        }
        
        var drugList:[Any] = Global.drug
        
        var temp:[Any] = []
        for i in 0..<drugList.count {
            if let item = drugList[i] as? [String:Any],
                let itemKey = item["key"] as? String {
                if key == itemKey {
                    
                } else {
                    temp.append(item)
                }
            }
        }
        
        Global.drug = temp
        
        self.loadData()
    }
}

class DrugListViewController: UIViewController {
    
    var enterPush:Bool = false
    
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var viewData: UIView!

    @IBOutlet weak var tableView: UITableView!
    var items:[String] = []
    var datas:[String:Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        Global.drug = []
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    func loadData() {
        var drugList:[Any] = Global.drug
        
        if drugList.count == 0 {
            self.viewEmpty.isHidden = false
            self.viewData.isHidden = true
        } else {
            self.viewEmpty.isHidden = true
            self.viewData.isHidden = false
        }
        
        self.datas.removeAll()
        self.items.removeAll()
        
        // key
        for i in 0..<drugList.count {
            if let item = drugList[i] as? [String:Any],
                let time = item["time"] as? String {
                self.datas[time] = []
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionAddButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugAddViewController") as! DrugAddViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
