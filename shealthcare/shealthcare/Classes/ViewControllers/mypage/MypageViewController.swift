//
//  MypageViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 13/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation



import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

import UserNotifications


import CoreMotion

import os.log

class MypageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var imageViewNewsNew: UIImageView!
    @IBOutlet weak var buttonNews: UIButton!
    
    @IBOutlet weak var genderBgView: UIView!
    
    @IBOutlet weak var genderBigImageView: UIImageView!
    @IBOutlet weak var genderSmallImageView: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAge: UILabel!
    
    
    @IBOutlet weak var regDateWeightLabel: UILabel!
    @IBOutlet weak var regDateHeightLabel: UILabel!
    
    @IBOutlet weak var weightEndLablel: UILabel!
    @IBOutlet weak var weightEndUnitLabel: UILabel!
    
    @IBOutlet weak var heightLablel: UILabel!
    @IBOutlet weak var heightUnitLabel: UILabel!
    
    @IBOutlet weak var bmiLablel: UILabel!
    @IBOutlet weak var bmiUnitLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var items:Array = Array<[String:String]>()
    var defaultItems:Array = Array<[String:String]>()
    var subs:Array = Array<[String:Array<[String:String]>]>()
    
    let isAppUpdate = Global.isAppUpdate
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if true {
            let font:UIFont = UIFont.systemFont(ofSize: 14.0)
            let attributedString = NSMutableAttributedString(string: "kg", attributes: [NSAttributedString.Key.font : font])
            attributedString.setAttributes([NSAttributedString.Key.font: font,
                                            NSAttributedString.Key.foregroundColor: UIColor.init(red: 122.0/255.0, green: 149.0/255.0, blue: 230.0/255.0, alpha: 1),
                                            NSAttributedString.Key.baselineOffset: 0], range: NSRange(location: 0, length: 2))
            self.weightEndUnitLabel.attributedText = attributedString
        }
        if true {
            let font:UIFont = UIFont.systemFont(ofSize: 14.0)
            let attributedString = NSMutableAttributedString(string: "cm", attributes: [NSAttributedString.Key.font : font])
            attributedString.setAttributes([NSAttributedString.Key.font: font,
                                            NSAttributedString.Key.foregroundColor: UIColor.init(red: 122.0/255.0, green: 149.0/255.0, blue: 230.0/255.0, alpha: 1),
                                            NSAttributedString.Key.baselineOffset: 0], range: NSRange(location: 0, length: 2))
            self.heightUnitLabel.attributedText = attributedString
        }
        if true {
            let font:UIFont = UIFont.systemFont(ofSize: 14.0)
            let superscript:UIFont = UIFont.systemFont(ofSize: 9.0)
            let attributedString = NSMutableAttributedString(string: "kg/m2", attributes: [NSAttributedString.Key.font : font])
            attributedString.setAttributes([NSAttributedString.Key.font: superscript,
                                            NSAttributedString.Key.foregroundColor: UIColor.init(red: 122.0/255.0, green: 149.0/255.0, blue: 230.0/255.0, alpha: 1),
                                            NSAttributedString.Key.baselineOffset: 5], range: NSRange(location: 4, length: 1))
            self.bmiUnitLabel.attributedText = attributedString
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // init data
        self.defaultItems.append(["depth":"1", "group":"010", "isOpen":"0", "icon":"ic_mypage_hospital", "title":"서비스 신청내역", "isSub":"0", "key":"reserve_history"])
        
//        self.defaultItems.append(["depth":"1", "group":"080", "isOpen":"0", "icon":"ic_coupon", "title":"구폰", "isSub":"1"])
//        self.defaultItems.append(["depth":"2", "group":"080", "title":"쿠폰 신청", "type":"1", "key":"voucher"])
//        self.defaultItems.append(["depth":"2", "group":"080", "title":"쿠폰 발급 내역", "type":"1", "key":"voucher"])
        
        self.defaultItems.append(["depth":"1", "group":"020", "isOpen":"0", "icon":"ic_mypage_target", "title":"나의목표", "isSub":"1"])
        self.defaultItems.append(["depth":"2", "group":"020", "title":"체중▪︎허리둘레", "type":"1", "key":"goal"])
        
        self.defaultItems.append(["depth":"1", "group":"030", "isOpen":"0", "icon":"ic_mypage_checklist", "title":"건강기록", "isSub":"1"])
        self.defaultItems.append(["depth":"2", "group":"030", "title":"걷기", "type":"1", "key":"walking"])
        self.defaultItems.append(["depth":"2", "group":"030", "title":"체중", "type":"1", "key":"weight"])
        self.defaultItems.append(["depth":"2", "group":"030", "title":"거북목측정", "type":"1", "key":"vertebra"])
        
        // 간병 + 진단후
        if Global.UserInfo!["CareNursing"]! == "1" &&
            Global.UserInfo!["CareNursingDiagnosis"]! == "2" {
            self.defaultItems.append(["depth":"1", "group":"050", "isOpen":"0", "icon":"ic_self_check", "title":"자가건강체크", "isSub":"1"])
            self.defaultItems.append(["depth":"2", "group":"050", "title":"치매위험도검사", "type":"1", "key":"dementia"])
            self.defaultItems.append(["depth":"2", "group":"050", "title":"간단건강테스트", "type":"1", "key":"moonjin"])
            
            self.defaultItems.append(["depth":"1", "group":"060", "isOpen":"0", "icon":"ic_contents", "title":"건강 콘텐츠", "isSub":"0", "key":"kakao_s-healthcare"])
            
            self.defaultItems.append(["depth":"1", "group":"070", "isOpen":"0", "icon":"ic_bone", "title":"경추밸런스", "isSub":"1"])
            self.defaultItems.append(["depth":"2", "group":"070", "title":"고개를들어요", "type":"1", "key":"HeadUp"])
            self.defaultItems.append(["depth":"2", "group":"070", "title":"거북목측정", "type":"1", "key":"TurtleNeck"])
            self.defaultItems.append(["depth":"2", "group":"070", "title":"예방가이드", "type":"1", "key":"prevention_guide"])
            
        }
        
        self.defaultItems.append(["depth":"1", "group":"040", "isOpen":"0", "icon":"ic_mypage_setup_small", "title":"설정", "isSub":"1"])
        self.defaultItems.append(["depth":"2", "group":"040", "title":"버전정보", "type":"2", "key":"appUpdate"])
        self.defaultItems.append(["depth":"2", "group":"040", "title":"개인정보관리", "type":"1", "key":"mypageEdit"])
        self.defaultItems.append(["depth":"2", "group":"040", "title":"알림설정", "type":"1", "key":"settingUrl"])
        self.defaultItems.append(["depth":"2", "group":"040", "title":"헬스케어센터연결", "type":"3", "key":"center"])
        
        
        for i in 0..<self.defaultItems.count {
            let _item = self.defaultItems[i]
            let _depth = _item["depth"]
            if _depth == "1" {
                self.items.append(_item)
            }
        }
        
        
//        // 공지사항 완료 체크
//        self.buttonNews.isHidden = true
//        checkNewsToComplate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Global.loadUserInfo { (result) in
            self.displayUserInfo()
        }
        self.displayUserInfo()
        
        self.imageViewNewsNew.isHidden = true
        self.checkNewsNew()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // 공지사항 개발완료 체크.
    func checkNewsToComplate() {
        let _url = "http://shealthcare.ichc.co.kr/notice/notice_list.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
        ]
        
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseString(encoding:String.Encoding.utf8, completionHandler: { (response) in
                if let val = response.result.value {
                    if val.contains("<title>삼성생명 S-헬스케어서비스</title>") {
                        self.buttonNews.isHidden = false
                    }
                }
            })
    }
    
    // 공지사항 새글 체크
    func checkNewsNew() {
        let _url = "http://app.ichc.co.kr/api/shealthcare/notice_new_check.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
        ]
        
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseData { (response) in
                if let data = response.data {
                    let xml = XML.parse(data)
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "1" {
                            self.imageViewNewsNew.isHidden = false
                        }
                    }
                }
        }
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 공지사항
    @IBAction func actionNewsPageButton(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.kind = "news"
        webViewController.isMenuShow = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // 개인정보 관리
    @IBAction func actionMypageEditButton(_ sender: Any) {
        let mypageEditViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageEditViewController") as! MypageEditViewController
        self.navigationController?.pushViewController(mypageEditViewController, animated: true)
    }
    
    

    // MARK: - Function
    func displayUserInfo() {
        
        let _gender:String = Global.UserInfo!["gender"]!
        let _name:String = Global.UserInfo!["name"]!
        let _age:Int = Global.UserInfo!["birthday"]!.ageKr()
        
        if _gender == "1" {
            self.genderBigImageView.image = UIImage(named: "ic_mypage_man")
            self.genderSmallImageView.image = UIImage(named: "ic_mypage_gender_man")
        } else {
            self.genderBigImageView.image = UIImage(named: "ic_mypage_woman")
            self.genderSmallImageView.image = UIImage(named: "ic_mypage_gender_woman")
        }
        
        self.labelName.text = _name
        self.labelAge.text = "현재 나이 만 : \(_age)"
        
        self.regDateWeightLabel.text = Global.UserInfo!["RegDateWeight"]!.toDate("yyyyMMdd")?.toString("yy.MM.dd")
        self.regDateHeightLabel.text = Global.UserInfo!["RegDateHeight"]!.toDate("yyyyMMdd")?.toString("yy.MM.dd")
        self.weightEndLablel.text = Global.UserInfo!["weightEnd"]!
        self.heightLablel.text = Global.UserInfo!["height"]!
        
        // 1. BMI 값 = 체중(kg) ÷ 키(m) 제곱
        // 예) 168cm / 60kg 의 경우,  60÷(1.68x1.68) = 20.8
        let _weight:Double = Double(Global.UserInfo!["weightEnd"]!)!
        let _height:Double = Double(Global.UserInfo!["height"]!)!
        
        let _bmi:Double = _weight / ((_height/100.0) * (_height/100.0))
        self.bmiLablel.text = String(format: "%.1f", arguments: [_bmi])
    }
    
    
    
    
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _item:[String:String] = self.items[indexPath.row]
        let _depth = _item["depth"]
        if _depth == "1" {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
            
            let imageView1:UIImageView = cell.viewWithTag(1) as! UIImageView
            let label2:UILabel = cell.viewWithTag(2) as! UILabel
            let imageView3:UIImageView = cell.viewWithTag(3) as! UIImageView
            
            let _icon:String = _item["icon"]!
            let _title:String = _item["title"]!
            let _isSub = _item["isSub"]!
            let _isOpen = _item["isOpen"]
            
            imageView1.image = UIImage(named: _icon)
            label2.text = _title
            if _isSub == "1" {
                imageView3.isHidden = false
            } else {
                imageView3.isHidden = true
            }
            
            if _isOpen == "1" {
                imageView3.image = UIImage.init(named: "ic_mypage_arrow_top")
            } else {
                imageView3.image = UIImage.init(named: "ic_mypage_arrow_bottom")
            }
            
            
            return cell
        } else {
            let _type = _item["type"]
            if _type == "2" {
                
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellSub2", for: indexPath) as UITableViewCell
                
                let label1:UILabel = cell.viewWithTag(1) as! UILabel
                let label2:UILabel = cell.viewWithTag(2) as! UILabel
                let label3:UILabel = cell.viewWithTag(3) as! UILabel
                
                let _title:String = _item["title"]!
                label1.text = _title
                
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                label2.text = String(format: "v%@", version ?? "")
                
                if isAppUpdate {
                    label3.text = "업데이트"
                } else {
                    label3.text = "최신"
                }
                
                return cell
            } else {
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellSub1", for: indexPath) as UITableViewCell
                
                let label2:UILabel = cell.viewWithTag(2) as! UILabel
                
                let _title:String = _item["title"]!
                label2.text = _title
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var _selectedItem = self.items[indexPath.row]
        
        if let _key = _selectedItem["key"] {
            // 개인정보관리
            if _key == "mypageEdit" {
                let mypageEditViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageEditViewController") as! MypageEditViewController
                self.navigationController?.pushViewController(mypageEditViewController, animated: true)
            }
                // 헬스케어센터연결
            else if _key == "center" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "call"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
                // 알림 설정
            else if _key == "settingUrl" {
                let vc = NotiSettingViewController.initStoryboard()
                self.navigationController?.pushViewController(vc, animated: true)
                
//                if let url = URL(string: UIApplication.openSettingsURLString) {
//                    if UIApplication.shared.canOpenURL(url) {
//                        _ =  UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }
            }
            // 체중,허리둘레 목표
            else if _key == "goal" {
                let goalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GoalViewController") as! GoalViewController
                self.navigationController?.pushViewController(goalViewController, animated: true)
            }
            // 서비스 신청내역
            else if _key == "reserve_history" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "reserve_history"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            // 업데이트
            else if _key == "appUpdate" {
                if isAppUpdate {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id1455598910"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
                
            // 거북목 측정 기록
            else if _key == "vertebra" {
                let turtleNeckResultViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckResultViewController") as! TurtleNeckResultViewController
                self.navigationController?.pushViewController(turtleNeckResultViewController, animated: true)
            }
            // 체중관리
            else if _key == "weight" {
                let weightViewController = UIStoryboard(name: "Weight", bundle: nil).instantiateViewController(withIdentifier: "WeightViewController") as! WeightViewController
                self.navigationController?.pushViewController(weightViewController, animated: true)
            }
            // 걷기
            else if _key == "walking" {
                let vc = UIStoryboard(name: "Walking", bundle: nil).instantiateViewController(withIdentifier: "WalkingViewController")
                self.navigationController?.pushViewController(vc, animated: true)
            }
                
            // 자가건강체크(치매)
            else if _key == "dementia" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "dementia"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            // 자가건강체크(간단건강테스트)
            else if _key == "moonjin" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "moonjin"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            // 건강 컨텐츠
            else if _key == "kakao_s-healthcare" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "kakao_s-healthcare"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            
            // 고개를들어요
            else if _key == "HeadUp" {
                let headUpViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "HeadUpViewController") as! HeadUpViewController
                self.navigationController?.pushViewController(headUpViewController, animated: true)
            }
            // 거북목측정
            else if _key == "TurtleNeck" {
                let turtleNeckViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckViewController") as! TurtleNeckViewController
                self.navigationController?.pushViewController(turtleNeckViewController, animated: true)
            }
            // 예방가이드
            else if _key == "prevention_guide" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "prevention_guide"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            
            // 쿠폰
            else if _key == "voucher" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "voucher"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            
            return
        }
        
        
        
        
        let _depth = _selectedItem["depth"]
        if _depth == "1" {
            let _group = _selectedItem["group"]
            let _isOpen = _selectedItem["isOpen"]
            
            if _isOpen == "1" {
                _selectedItem["isOpen"] = "0"
            } else {
                _selectedItem["isOpen"] = "1"
            }
            
            self.items[indexPath.row] = _selectedItem
            
            if _selectedItem["isOpen"] == "1" {
                var _arr = Array<[String:String]>()
                for i in 0..<self.defaultItems.count {
                    let _item = self.defaultItems[i]
                    if _item["depth"] == "2" && _item["group"] == _group {
                        _arr.append(_item)
                    }
                }
                self.items.insert(contentsOf: _arr, at: indexPath.row+1)
                tableView.reloadData()
            } else {
                var _arr = Array<[String:String]>()
                for i in 0..<self.items.count {
                    let _item = self.items[i]
                    if _item["depth"] == "2" && _item["group"] == _group {
                        _arr.append(_item)
                    }
                }
                self.items = self.items.filter{!_arr.contains($0)}
                tableView.reloadData()
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
