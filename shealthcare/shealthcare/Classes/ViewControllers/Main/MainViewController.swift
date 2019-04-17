//
//  MainViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 12/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

import UserNotifications

import HealthKit

import CoreMotion

import ActionKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var introImageView: UIImageView!
    
    
    var loginViewController: LoginViewController?
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var items:Array = Array<[String:String]>()
    var colors:Array = Array<UIColor>()

    let healthStore = HKHealthStore()
    var walkingCount:Int = 0
    
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthStore.execute(query)
    }
    
    var labelWalking:UILabel? = nil
    
    var pedometer = CMPedometer()
    
    @objc func observerPushDrug(notfication: NSNotification) {
        self.navigationController?.popToRootViewController(animated: false)
        
        let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugTodayListViewController") as! DrugTodayListViewController
        vc.userInfo = notfication.userInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func observerPushDrugComplate(notfication: NSNotification) {
        self.navigationController?.popToRootViewController(animated: false)
        
        let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugComplateViewController") as! DrugComplateViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerPushDrug(notfication:)), name: .drug, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(observerPushDrugComplate(notfication:)), name: .drugComplate, object: nil)
        
        if CMPedometer.isStepCountingAvailable() {
            let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!

            pedometer.startUpdates(from: startDate) { (data, error) in
                if let data = data {
                    self.walkingCount = data.numberOfSteps.intValue
                    for (i, item) in self.items.enumerated() {
                        if item["kind"] == "walking" {
                            DispatchQueue.main.async(execute: {
                                self.collectionView.reloadItems(at: [IndexPath.init(item: i, section: 0)])
                            })
                            break;
                        }
                    }
                }
                
                Global.serverAddWalking(date: Date()) { (result) in
                    debugPrint("result = \(result)")
                }
            }
        }
        
        DispatchQueue.global().async {
            while Global.serverAddDevicePushKey() == false {
                debugPrint("serverAddDevicePushKey false")
                sleep(10)
            }
        }
        
        // Do any additional setup after loading the view.
        self.view.isHidden = true
        
        self.view.bringSubviewToFront(self.introImageView)
        
        let _autoLoginOn = UserDefaults.standard.bool(forKey: DefineUserDefaults.autoLoginOn.rawValue)
        if _autoLoginOn && true {
            memInfo()
        } else {
            loginViewControllerShow()
        }
        
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        
        // 10개 컬러
        self.colors.append(UIColor.init(red: 43.0/255.0, green: 112.0/255.0, blue: 175.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 53.0/255.0, green: 133.0/255.0, blue: 203.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 92.0/255.0, green: 155.0/255.0, blue: 214.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 41.0/255.0, green: 101.0/255.0, blue: 156.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 43.0/255.0, green: 112.0/255.0, blue: 175.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 41.0/255.0, green: 101.0/255.0, blue: 156.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 43.0/255.0, green: 112.0/255.0, blue: 175.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 92.0/255.0, green: 155.0/255.0, blue: 214.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 53.0/255.0, green: 133.0/255.0, blue: 203.0/255.0, alpha: 1))
        self.colors.append(UIColor.init(red: 87.0/255.0, green: 153.0/255.0, blue: 214.0/255.0, alpha: 1))
        
        
        // test
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Global.drugResetNoti()
    }
    
    // MARK: - test
    
    // MARK: - Function
    public func loginViewControllerShow() {
        UserDefaults.standard.set(false, forKey: DefineUserDefaults.autoLoginOn.rawValue)
        
        let loginNavigatonController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigatonController") as! BaseNavigationController
        self.navigationController!.present(loginNavigatonController, animated: false, completion: nil)
        
        loginViewController = loginNavigatonController.viewControllers[0] as? LoginViewController
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: .loginSuccess, object: loginViewController)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    @objc func loginSuccess() {
        debugPrint("loginSuccess")
        
        // 로그인 성공.
        if let _loginViewController = loginViewController {
            NotificationCenter.default.removeObserver(_loginViewController)
        }
        loginViewController?.dismiss(animated: false, completion: nil)
        
        memInfo()
    }
    
    
    func memInfo() {
        if let lastWalking = UserDefaults.standard.string(forKey: DefineUserDefaults.walking.rawValue),
            let lastWalkingDate = lastWalking.toDate("yyyyMMdd"),
            let yesterdayDate = lastWalkingDate.addDay(-1) {
            
            let group = DispatchGroup()
            var date = yesterdayDate
            while Date().compare(date) == .orderedDescending {
                debugPrint("date = \(date.toString("yyyyMMdd"))")
                group.enter()
                Global.serverAddWalking(date: date) { (result) in
                    group.leave()
                }
                date = date.addDay(1)!
            }
        }
        
        
        
        self.introImageView.isHidden = true
        
        // Guide 가이드 팝업.
        let _isGuidePopup = UserDefaults.standard.bool(forKey: DefineUserDefaults.guidePopup.rawValue + UIApplication.shared.applicationBuild())
        if _isGuidePopup == false {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuidePopupViewController")
            vc.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false, completion: nil)
        }
        // old
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermNavigationController")
//        vc.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
//        vc.modalPresentationStyle = .overCurrentContext
//        self.present(vc, animated: false, completion: nil)
        
        
        
        self.view.isHidden = false
        
        MKProgress.show()
        Global.loadUserInfo { (result) in
            MKProgress.hide()
            if result == 1 {
                self.showMenuType()
            } else if result == 2 {
                // 로그아웃 -> 로그인 화면 활성화
                self.loginViewControllerShow()
                return
            } else {
                "통신중 오류가 발생하였습니다.".alert(self)
            }
        }
        
        Global.loadingSuccess = true
    }
    
    func showMenuType() {
        self.items.removeAll()
        
//        <CareNursing>간병:1,0</CareNursing>
//        <CareCancer>암:1,0</CareCancer>
//        <CareDiabetes>당뇨:1,0</CareDiabetes>
//        <CareNursingDiagnosis>간병_진단전1</CareNursingDiagnosis>
//        <CareNursingDiagnosisDementia>간병_진단후_CDR-1,3</CareNursingDiagnosisDementia>
//        <CareNursingDiagnosisLongTermCare>간병_진단후_장기요양-1,3</CareNursingDiagnosisLongTermCare >
//        <CareCancerDiagnosis>암_진단-전1,후2</CareCancerDiagnosis>
//        <CareDiabetesDiagnosis>당뇨_진단-전1,후2</CareDiabetesDiagnosis>
        
//        Global.UserInfo!["CareNursingDiagnosis"] = "2"
//        Global.UserInfo!["CareNursingDiagnosisDementia"] = "1"
//        Global.UserInfo!["CareNursingDiagnosisDementia"] = "3"
//        Global.UserInfo!["CareNursingDiagnosisLongTermCare"] = "1"
//        Global.UserInfo!["CareNursingDiagnosisLongTermCare"] = "3"
        
        
        // 간병 + 진단전
        if Global.UserInfo!["CareNursing"]! == "1" &&
            Global.UserInfo!["CareNursingDiagnosis"]! == "1" {
            self.items.append(["title":"검진▪︎진료", "imageName":"ic_menu01_medical", "kind":"medical"])
            self.items.append(["title":"건강 콘텐츠", "imageName":"ic_menu02_contents", "kind":"kakao_s-healthcare"])
            
            self.items.append(["title":"경추 밸러스", "imageName":"ic_menu04_vertebra", "kind":"vertebra"])
            self.items.append(["title":"걸음", "imageName":"ic_main12_walking", "kind":"walking"])
            self.items.append(["title":"복약 알림", "imageName":"ic_menu05_drug", "kind":"drug"])
            
            self.items.append(["title":"체중 관리", "imageName":"ic_menu03_weight", "kind":"weight"])
            self.items.append(["title":"자가건강체크", "imageName":"ic_menu07_checkup", "kind":"checkup"])
            self.items.append(["title":"독서 안경", "imageName":"ic_menu08_magnifier", "kind":"magnifier"])
            
            self.items.append(["title":"응급포털", "imageName":"ic_menu09_emergency", "kind":"emergency"])
            self.items.append(["title":"헬스케어센터", "imageName":"ic_menu10_call", "kind":"call"])
        }
        
        // 간병 + 진단후 + 경증치매(CDR1,2점)
        if Global.UserInfo!["CareNursing"]! == "1" &&
            Global.UserInfo!["CareNursingDiagnosis"]! == "2" &&
            (Global.UserInfo!["CareNursingDiagnosisDementia"] == "1" || Global.UserInfo!["CareNursingDiagnosisDementia"] == "2") {
            self.items.append(["title":"검진▪︎진료", "imageName":"ic_menu01_medical", "kind":"medical"])
            self.items.append(["title":"뇌 트레이닝", "imageName":"ic_main13_brain", "kind":"brain"])
            
            self.items.append(["title":"간병인 지원", "imageName":"ic_main15_care", "kind":"care"])
            self.items.append(["title":"걸음", "imageName":"ic_main12_walking", "kind":"walking"])
            self.items.append(["title":"치매안심지원", "imageName":"ic_main16_dementia", "kind":"dementia"])
            
            self.items.append(["title":"체중 관리", "imageName":"ic_menu03_weight", "kind":"weight"])
            self.items.append(["title":"복약 알림", "imageName":"ic_menu05_drug", "kind":"drug"])
            self.items.append(["title":"독서 안경", "imageName":"ic_menu08_magnifier", "kind":"magnifier"])
            
            self.items.append(["title":"응급포털", "imageName":"ic_menu09_emergency", "kind":"emergency"])
            self.items.append(["title":"헬스케어센터", "imageName":"ic_menu10_call", "kind":"call"])
        }
        
        // 간병 + 진단후 + 경증간병(장기요양3,4등급)
        if Global.UserInfo!["CareNursing"]! == "1" &&
            Global.UserInfo!["CareNursingDiagnosis"]! == "2" &&
            (Global.UserInfo!["CareNursingDiagnosisLongTermCare"] == "3" || Global.UserInfo!["CareNursingDiagnosisLongTermCare"] == "4") {
            self.items.append(["title":"검진▪︎진료", "imageName":"ic_menu01_medical", "kind":"medical"])
            self.items.append(["title":"간병인 지원", "imageName":"ic_main15_care", "kind":"care"])
            
            self.items.append(["title":"건강 콘텐츠", "imageName":"ic_menu02_contents", "kind":"kakao_s-healthcare"])
            self.items.append(["title":"걸음", "imageName":"ic_main12_walking", "kind":"walking"])
            self.items.append(["title":"복약 알림", "imageName":"ic_menu05_drug", "kind":"drug"])
            
            self.items.append(["title":"체중 관리", "imageName":"ic_menu03_weight", "kind":"weight"])
            self.items.append(["title":"자가건강체크", "imageName":"ic_menu07_checkup", "kind":"checkup"])
            self.items.append(["title":"독서 안경", "imageName":"ic_menu08_magnifier", "kind":"magnifier"])
            
            self.items.append(["title":"응급포털", "imageName":"ic_menu09_emergency", "kind":"emergency"])
            self.items.append(["title":"헬스케어센터", "imageName":"ic_menu10_call", "kind":"call"])
        }
        
        // 간병 + 진단후 + 중증치매(3점이상)
        if Global.UserInfo!["CareNursing"]! == "1" &&
            Global.UserInfo!["CareNursingDiagnosis"]! == "2" &&
            (Global.UserInfo!["CareNursingDiagnosisDementia"]!.toInt() >= 3) {
            self.items.append(["title":"검진▪︎진료", "imageName":"ic_menu01_medical", "kind":"medical"])
            self.items.append(["title":"요양 지원", "imageName":"ic_main14_cresupport", "kind":"convalescence"])
            
            self.items.append(["title":"치매안심지원", "imageName":"ic_main16_dementia", "kind":"dementia"])
            self.items.append(["title":"뇌 트레이닝", "imageName":"ic_main13_brain", "kind":"brain"])
            self.items.append(["title":"간병인 지원", "imageName":"ic_main15_care", "kind":"care"])
            
            self.items.append(["title":"체중 관리", "imageName":"ic_menu03_weight", "kind":"weight"])
            self.items.append(["title":"복약 알림", "imageName":"ic_menu05_drug", "kind":"drug"])
            self.items.append(["title":"독서 안경", "imageName":"ic_menu08_magnifier", "kind":"magnifier"])
            
            self.items.append(["title":"응급포털", "imageName":"ic_menu09_emergency", "kind":"emergency"])
            self.items.append(["title":"헬스케어센터", "imageName":"ic_menu10_call", "kind":"call"])
        }
        
        // 간병 + 진단후 + 중증간병(1,2등급)
        if Global.UserInfo!["CareNursing"]! == "1" &&
            Global.UserInfo!["CareNursingDiagnosis"]! == "2" &&
            (Global.UserInfo!["CareNursingDiagnosisLongTermCare"]! == "1" || Global.UserInfo!["CareNursingDiagnosisLongTermCare"]! == "2") {
            self.items.append(["title":"검진▪︎진료", "imageName":"ic_menu01_medical", "kind":"medical"])
            self.items.append(["title":"요양 지원", "imageName":"ic_main14_cresupport", "kind":"convalescence"])
            
            self.items.append(["title":"복약 알림", "imageName":"ic_menu05_drug", "kind":"drug"])
            self.items.append(["title":"걸음", "imageName":"ic_main12_walking", "kind":"walking"])
            self.items.append(["title":"간병인 지원", "imageName":"ic_main15_care", "kind":"care"])
            
            self.items.append(["title":"체중 관리", "imageName":"ic_menu03_weight", "kind":"weight"])
            self.items.append(["title":"건강 콘텐츠", "imageName":"ic_menu02_contents", "kind":"kakao_s-healthcare"])
            self.items.append(["title":"독서 안경", "imageName":"ic_menu08_magnifier", "kind":"magnifier"])
            
            self.items.append(["title":"응급포털", "imageName":"ic_menu09_emergency", "kind":"emergency"])
            self.items.append(["title":"헬스케어센터", "imageName":"ic_menu10_call", "kind":"call"])
        }
        
        if let _menus = UserDefaults.standard.object(forKey: DefineUserDefaults.menus.rawValue) as? Array<[String:String]> {
            var count = 0
            for item in self.items {
                if _menus.contains(item) {
                    count = count + 1
                }
            }
            if _menus.count == self.items.count &&
                self.items.count == count {
                self.items = _menus
            }
        }
        
        self.collectionView.reloadData()
    }
    
    
    // MARK: - Action
    @IBAction func actionMypageButton(_ sender: Any) {
        let mypageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageViewController") as! MypageViewController
        self.navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    @IBAction func actionCallButton(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.kind = "call"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // MARK: - UICollectionView Delegate
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        debugPrint("Starting Index = %d", sourceIndexPath.item)
//        debugPrint("Ending Index = %d", destinationIndexPath.item)

        let item = self.items.remove(at: sourceIndexPath.item)
        self.items.insert(item, at: destinationIndexPath.item)
        
//        debugPrint(items)
        
        UserDefaults.standard.set(self.items, forKey: DefineUserDefaults.menus.rawValue)
        
        for cell in self.collectionView.visibleCells {
            let indexPath:IndexPath = self.collectionView.indexPath(for: cell)!
            
            let view1:UIView = cell.viewWithTag(1)!
            
            let mod = indexPath.item % 10
            view1.backgroundColor = self.colors[mod]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftPadding:CGFloat = 10.0
        let topPadding:CGFloat = 10.0
        let rightPadding:CGFloat = 10.0
        let bottomPadding:CGFloat = 10.0
        
        let minSpace:CGFloat = 5.0
        let minLine:CGFloat = 5.0
        
        let width:CGFloat = collectionView.bounds.size.width - leftPadding - rightPadding
        let height:CGFloat = collectionView.bounds.size.height - topPadding - bottomPadding
        
//        if indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 8 || indexPath.item == 9 {
//            return CGSize(width: (width - (minSpace * 1.0)) / 2.0, height: (height - (minLine * 4.0)) / 4.0)
//        } else {
//            return CGSize(width: ceil((width - (minSpace * 3.0)) / 3.0), height: (height - (minLine * 4.0)) / 4.0)
//        }
        
        // 4줄
        var _maxLine:CGFloat = 4.0
        
        let cellCount1 = CGSize(width: width, height: (height - (minLine * _maxLine)) / _maxLine)
        let cellCount2 = CGSize(width: (width - (minSpace * 1.0)) / 2.0, height: (height - (minLine * _maxLine)) / _maxLine)
        let cellCount3 = CGSize(width: (width - (minSpace * 2.0)) / 3.0, height: (height - (minLine * _maxLine)) / _maxLine)
        
        if self.items.count == 10 {
            let itemArray = [2,3,4,5,6,7]
            if itemArray.contains(indexPath.item) {
                return cellCount3
            }
            
            // 2개 짜리
            return cellCount2
        }
        
        // 1개 짜리
        return cellCount1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let item:[String:String] = self.items[indexPath.item]
        let kind = item["kind"]
        if kind == "walking" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellWalking", for: indexPath as IndexPath) as UICollectionViewCell
            
            let view1:UIView = cell.viewWithTag(1)!
            let imageView2:UIImageView = cell.viewWithTag(2) as! UIImageView
            let label3:UILabel = cell.viewWithTag(3) as! UILabel
            let label4:UILabel = cell.viewWithTag(4) as! UILabel
            
            imageView2.image = UIImage(named: item["imageName"] ?? "")
            label3.text = item["title"] ?? ""
            
            let mod = indexPath.item % 10
            view1.backgroundColor = self.colors[mod]
            
            label4.text = self.walkingCount.toString()
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as UICollectionViewCell
            
            let view1:UIView = cell.viewWithTag(1)!
            let imageView2:UIImageView = cell.viewWithTag(2) as! UIImageView
            let label3:UILabel = cell.viewWithTag(3) as! UILabel
            
            imageView2.image = UIImage(named: item["imageName"] ?? "")
            label3.text = item["title"] ?? ""
            
            let mod = indexPath.item % 10
            view1.backgroundColor = self.colors[mod]
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
//        let startDate = Date().addSec(30)!
//        Global.everydayNotification(type:"DRUGTIME", date: startDate, body: "Test!!!", userInfo: [
//            "type": "DRUGTIME",
//            "datetime": startDate.toString("yyyyMMddHHmmss")
//            ])
        
        let _item:[String:String] = self.items[indexPath.item]
        if let _kind = _item["kind"], _kind.count > 0 {
            // 검진▪︎진료, 응급포털, 헬스케어센터, 자가건강체크
            if _kind == "medical"
                || _kind == "emergency"
                || _kind == "call"
                || _kind == "checkup"
            {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = _kind
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            // 건강 컨텐츠
            else if _kind == "kakao_s-healthcare" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "kakao_s-healthcare"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
                
            // 체중 관리
            else if _kind == "weight" {
                let weightViewController = UIStoryboard(name: "Weight", bundle: nil).instantiateViewController(withIdentifier: "WeightViewController") as! WeightViewController
                self.navigationController?.pushViewController(weightViewController, animated: true)
            }
                
            // 경추 밸러스
            else if _kind == "vertebra" {
//                let headUpViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "HeadUpViewController") as! HeadUpViewController
//                self.navigationController?.pushViewController(headUpViewController, animated: true)
                let turtleNeckViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckViewController") as! TurtleNeckViewController
                self.navigationController?.pushViewController(turtleNeckViewController, animated: true)
            }
                
            // 복약 알림
            else if _kind == "drug" {
                let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugListViewController") as! DrugListViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            // 독서 안경
            else if _kind == "magnifier" {
                let vc = UIStoryboard(name: "Glasses", bundle: nil).instantiateViewController(withIdentifier: "GlassesViewController") as! GlassesViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
                
            // 뇌 트레이닝
            else if _kind == "brain" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "brain"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
                
                // 요양 지원
            else if _kind == "convalescence" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "convalescence"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
                
                // 간병인 지원
            else if _kind == "care" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "care"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
                
                // 치매안심지원
            else if _kind == "dementia" {
                let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.kind = "dementia"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
            
                // 걷기
            else if _kind == "walking" {
                let vc = UIStoryboard(name: "Walking", bundle: nil).instantiateViewController(withIdentifier: "WalkingViewController")
                self.navigationController?.pushViewController(vc, animated: true)
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
