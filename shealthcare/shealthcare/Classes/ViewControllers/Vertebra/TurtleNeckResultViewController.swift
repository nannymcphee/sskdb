//
//  TurtleNeckResultViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 21/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class TurtleNeckResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewList1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList3HeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelDate: UILabel!
    var items:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if let _items = UserDefaults.standard.array(forKey: DefineUserDefaults.turtleNeckList.rawValue) {
            self.items = _items.sorted(by: {
                if let d1 = (($0 as! [String:Any])["datetime"] as? Date),
                     let d2 = (($1 as! [String:Any])["datetime"] as? Date)
                {
                    return d1 > d2
                }
                return false
            })
            if self.items.count > 0 {
                let _firstItem:[String:Any] = self.items.last as! [String : Any]
                let _endItem:[String:Any] = self.items.first as! [String : Any]
                let _firstDt:Date = _firstItem["datetime"] as! Date
                let _lastDt:Date = _endItem["datetime"] as! Date
                labelDate.text = String(format: "%@  ~  %@", _firstDt.toString("yyyy.MM.dd HH:mm"), _lastDt.toString("yyyy.MM.dd HH:mm"))
            } else {
                labelDate.text = "~"
            }
        }
        
        
        self.viewList1HeightConstraint.constant = 0
        self.viewList2HeightConstraint.constant = 0
        self.viewList3HeightConstraint.constant = 0
    }
    
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionMenuButton(_ sender: Any) {
        let mypageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageViewController") as! MypageViewController
        self.navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    @IBAction func actionListButton(_ sender: Any) {
        if self.viewList1HeightConstraint.constant == 0 {
            self.viewList1HeightConstraint.constant = 49
            self.viewList2HeightConstraint.constant = 49
            self.viewList3HeightConstraint.constant = 49
        } else {
            self.viewList1HeightConstraint.constant = 0
            self.viewList2HeightConstraint.constant = 0
            self.viewList3HeightConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        //        UIView.animate(withDuration: 0.5, animations: {
        //            self.view.layoutIfNeeded()
        //        }) { (Bool) in
        //
        //        }
    }
    
    // 예방가이드
    @IBAction func actionPreventionGuide(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.kind = "prevention_guide"
        self.navigationController?.pushViewController(webViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 고개를 들어요
    @IBAction func actionHeadUpButton(_ sender: Any) {
        let headUpViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "HeadUpViewController") as! HeadUpViewController
        self.navigationController?.pushViewController(headUpViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 거북목 측정
    @IBAction func actionTurtleNeckButton(_ sender: Any) {
        let turtleNeckViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckViewController") as! TurtleNeckViewController
        self.navigationController?.pushViewController(turtleNeckViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 측정 기록
    @IBAction func actionResultButton(_ sender: Any) {
        let turtleNeckResultViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckResultViewController") as! TurtleNeckResultViewController
        self.navigationController?.pushViewController(turtleNeckResultViewController, animated: true)
    }
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let label1:UILabel = cell.viewWithTag(1) as! UILabel
        let label2:UILabel = cell.viewWithTag(2) as! UILabel
        
        if let button99:UIButton = cell.viewWithTag(99) as? UIButton {
            button99.tag = indexPath.row
            button99.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        }
        
        let _item:[String:Any] = self.items[indexPath.row] as! [String : Any]
        let _datetime:Date = _item["datetime"] as! Date
        let _record:CGFloat = _item["record"] as! CGFloat
        label1.text = _datetime.toString("yyyy.MM.dd HH:mm")
        label2.text = String(format: "%d°", Int(_record))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("indexPath.row = \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    @objc func buttonClicked(sender:UIButton) {
        self.items.remove(at: sender.tag)
        tableView.reloadData()
        UserDefaults.standard.set(self.items, forKey: DefineUserDefaults.turtleNeckList.rawValue)
        
        if self.items.count > 0 {
            let _firstItem:[String:Any] = self.items.last as! [String : Any]
            let _endItem:[String:Any] = self.items.first as! [String : Any]
            let _firstDt:Date = _firstItem["datetime"] as! Date
            let _lastDt:Date = _endItem["datetime"] as! Date
            labelDate.text = String(format: "%@  ~  %@", _firstDt.toString("yyyy.MM.dd HH:mm"), _lastDt.toString("yyyy.MM.dd HH:mm"))
        } else {
            labelDate.text = "~"
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
