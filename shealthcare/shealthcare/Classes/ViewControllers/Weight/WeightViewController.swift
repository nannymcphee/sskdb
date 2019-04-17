//
//  WeightViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 18/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

import HcdDateTimePicker

class WeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var dateShotLabel: UILabel!
    @IBOutlet weak var dateLongLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var weakupButton: UIButton!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var weightSaveButton: UIButton!
    
    
    @IBOutlet weak var weightTextField: UITextField!
    
    var now = Date()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var items:[String] = []
    var orgDic:[String:[String:String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        display()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadData()
    }
    
    // MARK: - Function
    func display() {
        
        self.dateShotLabel.text = now.toString("yyyy년 M월")
        self.dateLongLabel.text = now.toString("yyyy년 M월 d일")
        self.dateTimeLabel.text = now.toString("a h:m")
        
        
    }
    
    func loadData() {
        
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/weight_list.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "kind": "4w",
        ]
        
        MKProgress.show()
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseData { (response) in
                MKProgress.hide()
                if let data = response.data {
                    let xml = XML.parse(data)
                    debugPrint(data.toStringKr())
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            self.items.removeAll()
                            self.orgDic.removeAll()
                            
                            var _dic:[String:String] = [:]
                            for item in xml.OUTPUT.Record.Item {
                                if let recDate = item.RecDate.text {
                                    _dic[recDate] = "true"
                                }
                                let row = [
                                    "seq":item.seq.text ?? "",
                                    "RecDate":item.RecDate.text ?? "",
                                    "RecTime":item.RecTime.text ?? "",
                                    "kind":item.kind.text ?? "",
                                    "Weight":item.Weight.text ?? "",
                                    ]
                                
                                self.orgDic[row["RecDate"]!+row["kind"]!] = row
                            }
                            
                            self.items = Array(_dic.keys).sorted(by: { $0 > $1 })
                            
                            self.tableView.reloadData()
                            
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    // MARK: - Notification Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.constraint_bottom.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constraint_bottom.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 101, string.count > 0 {
            if string == ".", (textField.text?.components(separatedBy: ".").count)! > 1 {
                return false
            }
            
            if (textField.text?.components(separatedBy: ".").count)! > 1, textField.text?.components(separatedBy: ".")[1].count == 1 {
                return false
            }
        }
        
        if let _text = textField.text, _text.count == 0, string == "." {
            return false
        }
        
        self.weightSaveButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let _weightText = self.weightTextField.text, _weightText.count > 0,
                (self.weakupButton.isSelected || self.sleepButton.isSelected){
                self.weightSaveButton.isEnabled = true
            }
        }
        
        return true
    }
    
    // 체중 등록
    func weightInsert(kind:Int) {
        self.view.endEditing(true)
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/weight_insert.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "wRegdate": self.now.toString("yyyyMMdd"),
            "wRegTime": self.now.toString("HHmm"),
            "kind": String(kind),
            "weight": self.weightTextField.text!
        ]
        
        MKProgress.show()
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseData { (response) in
                MKProgress.hide()
                if let data = response.data {
                    let xml = XML.parse(data)
                    debugPrint(data.toStringKr())
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            self.loadData()
                            self.weightTextField.text = ""
                            self.weakupButton.isSelected = false
                            self.sleepButton.isSelected = false
                            self.weightSaveButton.isEnabled = false
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // 체중 통계
    @IBAction func actionGraphButton(_ sender: Any) {
        let weightGraphViewController = UIStoryboard(name: "Weight", bundle: nil).instantiateViewController(withIdentifier: "WeightGraphViewController")
        self.navigationController?.pushViewController(weightGraphViewController, animated: true)
    }
    // 가이드 팝업.
    @IBAction func actionGuidePopupButton(_ sender: Any) {
        let weightGuidePopupViewController = UIStoryboard(name: "Weight", bundle: nil).instantiateViewController(withIdentifier: "WeightGuidePopupViewController")
        weightGuidePopupViewController.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        weightGuidePopupViewController.modalPresentationStyle = .overCurrentContext
        self.present(weightGuidePopupViewController, animated: true, completion: nil)
    }
    
    @IBAction func actionAgoMonthButton(_ sender: Any) {
        self.now.month(-1)
        display()
    }
    @IBAction func actionNextMonthButton(_ sender: Any) {
        self.now.month(1)
        display()
    }
    
    @IBAction func actionDateTimeButton(_ sender: Any) {
        self.view.endEditing(true)
        
        if let dateTimePickerView = HcdDateTimePickerView.init(datePickerMode: DatePickerDateHourMinuteMode, defaultDateTime: now) {
            dateTimePickerView.clickedOkBtn = { (str) in
                if let _date = str?.toDate("yyyy-M-d HH:mm") {
                    self.now = _date
                }
                self.display()
            }
            self.view.addSubview(dateTimePickerView)
            dateTimePickerView.showHcdDateTimePicker()
        }
    }
    
    // 기상 후
    @IBAction func actionWakeupButton(_ sender: Any) {
        self.view.endEditing(true)
        
        let _button = sender as! UIButton
        if _button.isSelected == true {
            _button.isSelected = false
        } else {
            _button.isSelected = true
            self.sleepButton.isSelected = false
        }
        
        if let _weightText = self.weightTextField.text, _weightText.count > 0,
            (self.weakupButton.isSelected || self.sleepButton.isSelected) {
            self.weightSaveButton.isEnabled = true
        } else {
            self.weightSaveButton.isEnabled = false
        }
    }
    // 기상 전
    @IBAction func actionSleepButton(_ sender: Any) {
        self.view.endEditing(true)
        
        let _button = sender as! UIButton
        if _button.isSelected == true {
            _button.isSelected = false
        } else {
            _button.isSelected = true
            self.weakupButton.isSelected = false
        }
        
        if let _weightText = self.weightTextField.text, _weightText.count > 0,
            (self.weakupButton.isSelected || self.sleepButton.isSelected) {
            self.weightSaveButton.isEnabled = true
        } else {
            self.weightSaveButton.isEnabled = false
        }
    }
    
    
    // 저장
    @IBAction func actionWeightSaveButton(_ sender: Any) {
        if self.weakupButton.isSelected {
            weightInsert(kind: 1)
        }
        if self.sleepButton.isSelected {
            weightInsert(kind: 2)
        }
    }
    

    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.items.count == 0 {
            return 300
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count == 0 {
            return 1
        }
        return self.items.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.items.count == 0 {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as UITableViewCell
            return cell
        }
        
        if indexPath.row % 2 == 0 {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as UITableViewCell
            
            let view1:UIView = cell.viewWithTag(1) as! UIView
            let label2:UILabel = cell.viewWithTag(2) as! UILabel
            let label3:UILabel = cell.viewWithTag(3) as! UILabel
            
            label2.text = ""
            label3.text = ""
            
            let _key = self.items[indexPath.row/2] + "1"
            if let _dic = self.orgDic[_key] {
                view1.isHidden = false
                if let recTime:String = _dic["RecTime"] {
                    label2.text = recTime.toDate("HHmm")?.toString("HH:mm")
                }
                if let weight:String = _dic["Weight"] {
                    label3.text = weight
                }
                if let button99:UIButton = cell.viewWithTag(99) as? UIButton, let _seq:String = _dic["seq"] {
                    button99.tag = Int(_seq)!
                    button99.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
                }
            } else {
                view1.isHidden = true
            }
            
            
            
            // Group Day
            var _weight1:Double = 0.0
            var _weight2:Double = 0.0
            
            // 1
            if let _dic = self.orgDic[self.items[indexPath.row/2] + "1"],
                let _weight = _dic["Weight"] {
                _weight1 = Double(_weight)!
            }
            // 2
            if let _dic = self.orgDic[self.items[indexPath.row/2] + "2"],
                let _weight:String = _dic["Weight"] {
                _weight2 = Double(_weight)!
            }
            
            let label101:UILabel = cell.viewWithTag(101) as! UILabel
            let imageView102:UIImageView = cell.viewWithTag(102) as! UIImageView
            
            let _day = self.items[indexPath.row/2]
            if Date().toString("yyyyMMdd") == _day {
                label101.text = "오늘"
            } else {
                label101.text = _day.toDate("yyyyMMdd")?.toString("dd일")
            }
            
        
            if Global.getBMILevel(_weight1 > _weight2 ? _weight1 : _weight2) <= 1 {
                imageView102.image = UIImage.init(named: "ic_weight_management_list_point_green")
            } else if Global.getBMILevel(_weight1 > _weight2 ? _weight1 : _weight2) <= 2 {
                imageView102.image = UIImage.init(named: "ic_weight_management_list_point_orange")
            } else {
                imageView102.image = UIImage.init(named: "ic_weight_management_list_point_pink")
            }
            
            return cell
            
        } else {
            
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as UITableViewCell
            
            let view1:UIView = cell.viewWithTag(1) as! UIView
            let label2:UILabel = cell.viewWithTag(2) as! UILabel
            let label3:UILabel = cell.viewWithTag(3) as! UILabel
            
            label2.text = ""
            label3.text = ""
            
            
            let _key = self.items[indexPath.row/2] + "2"
            if let _dic = self.orgDic[_key] {
                view1.isHidden = false
                if let recTime:String = _dic["RecTime"] {
                    label2.text = recTime.toDate("HHmm")?.toString("HH:mm")
                }
                if let weight:String = _dic["Weight"] {
                    label3.text = weight
                }
                if let button99:UIButton = cell.viewWithTag(99) as? UIButton, let _seq:String = _dic["seq"] {
                    button99.tag = Int(_seq)!
                    button99.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
                }
            } else {
                view1.isHidden = true
            }
            
            
            
            
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    @objc func buttonClicked(sender:UIButton) {
        
        let buttonRow = sender.tag
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/weight_delete.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "seq": String(buttonRow),
        ]
        
        MKProgress.show()
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseData { (response) in
                MKProgress.hide()
                if let data = response.data {
                    let xml = XML.parse(data)
                    debugPrint(data.toStringKr())
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            self.loadData()
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
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
