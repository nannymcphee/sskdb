//
//  Global.swift
//  shealthcare
//
//  Created by SangWooKim on 12/03/2019.
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


class Global: NSObject {
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "woo")
    static func oslog(_ type: OSLogType, dso: UnsafeRawPointer = #dsohandle, log: OSLog = .default, _ message: StaticString, _ args: CVarArg...) {
        if #available(iOS 12.0, *) {
            os_log(type, dso:dso, log:log, message, args)
        } else {
            // Fallback on earlier versions
        }
    }
    
    static var loadingSuccess:Bool = false
    
    static var userid: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.userid.rawValue)
        }
        get {
            if let _val = UserDefaults.standard.string(forKey: DefineUserDefaults.userid.rawValue) {
                return _val
            }
            return nil
        }
        
    }
    
    static var ukey: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.ukey.rawValue)
        }
        get {
            if let _val = UserDefaults.standard.string(forKey: DefineUserDefaults.ukey.rawValue) {
                return _val
            }
            return nil
        }
    }
    
    static var drug: [Any] {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.drugList.rawValue)
            
            Global.drugResetNoti()
        }
        get {
            if let _val = UserDefaults.standard.array(forKey: DefineUserDefaults.drugList.rawValue) {
                return _val
            }
            return []
        }
    }
    
    static var drugReloadDate: Date {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.drugListReloadDate.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            if let _val = UserDefaults.standard.object(forKey: DefineUserDefaults.drugListReloadDate.rawValue) {
                return _val as! Date
            }
            UserDefaults.standard.set(Date(), forKey: DefineUserDefaults.drugListReloadDate.rawValue)
            return Date()
        }
    }
    
    static var todayDrugList: Any {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.drugTodayList.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            if let _val = UserDefaults.standard.object(forKey: DefineUserDefaults.drugTodayList.rawValue) {
                return _val
            }
            return []
        }
    }
    
    static var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.token.rawValue)
        }
        get {
            if let _val = UserDefaults.standard.string(forKey: DefineUserDefaults.token.rawValue) {
                return _val
            }
            return nil
        }
    }
    
    static var pushNoti: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.pushNoti.rawValue)
        }
        get {
            if let _val = UserDefaults.standard.object(forKey: DefineUserDefaults.pushNoti.rawValue) {
                return _val as! Bool
            }
            return true
        }
    }
    
    static var soundNoti: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.soundNoti.rawValue)
        }
        get {
            if let _val = UserDefaults.standard.object(forKey: DefineUserDefaults.soundNoti.rawValue) {
                return _val as! Bool
            }
            return true
        }
    }
    
    static func drugResetNoti() {
        
        var drugList:[Any] = Global.drug
        
        // key
        var datas:[String:String] = [:]
        for i in 0..<drugList.count {
            if let item = drugList[i] as? [String:Any],
                let time = item["time"] as? String {
                datas[time] = ""
            }
        }
        
        let group = DispatchGroup()
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            
            // Delete
            var temp:[String] = []
            for request in requests {
                if request.identifier.hasPrefix("DRUGTIME") {
                    temp.append(request.identifier)
                }
            }
            center.removeDeliveredNotifications(withIdentifiers: temp)
            center.removePendingNotificationRequests(withIdentifiers: temp)
            
            // Add
            for i in 0..<3 {
                for key in datas.keys {
                    guard let date = key.toDate("HHmm") else {
                        continue
                    }
                    
                    guard var startDate = Calendar.current.date(bySettingHour: date.hour, minute: date.minute, second: 0, of: Date()) else {
                        continue
                    }
                    
                    startDate = startDate.addDay(i)!
                    
                    if Date() > startDate {
                        continue
                    }
                    
                    if let _drug = Global.todayDrugList as? [String:Any],
                        let _date = _drug["date"] as? String, let _list = _drug["list"] as? [String] {
                        if _date == startDate.toString("yyyyMMdd") && _list.contains(startDate.toString("HHmm")) {
                            debugPrint("startDate = \(startDate)")
                            continue
                        }
                    }
                    
                    guard let nextDate = startDate.addMin(10) else {
                        continue
                    }
                    group.enter()
                    Global.everydayNotification(type:"DRUGTIME_" + startDate.toString("yyyyMMddHHmm"), date: startDate, body: "약물 투약 잊지마세요!", userInfo: [
                        "type": "DRUGTIME",
                        "time": startDate.toString("HHmm"),
                        "datetime": startDate.toString("yyyyMMddHHmmss")
                        ])
                    Global.everydayNotification(type:"DRUGTIME_" + startDate.toString("yyyyMMddHHmm") + "_NEXT", date: nextDate, body: "처방 받으신 약을 드셨나요? 드셨다면 투약 입력을 해주세요.", userInfo: [
                        "type": "DRUGTIME_NEXT",
                        "time": startDate.toString("HHmm"),
                        "datetime": startDate.toString("yyyyMMddHHmmss"),
                        "nexttime": nextDate.toString("yyyyMMddHHmmss"),
                        ])
                }
            }
        })
    }
    
    static func everydayNotification(type:String, date:Date, body:String, userInfo:[AnyHashable : Any]) {
        if pushNoti == false {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.body = body
        if soundNoti {
            content.sound = .default
        }
//        content.badge = 1
        content.userInfo = userInfo
        
        var dateComponents = DateComponents()
        dateComponents.year = date.year
        dateComponents.month = date.month
        dateComponents.day = date.day
        dateComponents.hour = date.hour
        dateComponents.minute = date.minute
        
        let identifier = String(format: "%@", type)
//        debugPrint("identifier = \(identifier)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    static var UserInfo: [String:String]? {
        set {
            UserDefaults.standard.set(newValue, forKey: DefineUserDefaults.userInfo.rawValue)
        }
        get {
            if let _val = UserDefaults.standard.dictionary(forKey: DefineUserDefaults.userInfo.rawValue) as? [String:String] {
                return _val
            }
            return nil
        }
    }
    
    // 앱스토어 버전 체크
    static var isAppUpdate: Bool {
        get {
            guard
                let shortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let version = Float(shortVersionString),
                let url = URL(string: "http://itunes.apple.com/lookup?bundleId=kr.co.ichc.shealthcare"),
                let data = try? Data(contentsOf: url),
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let results = json?["results"] as? [[String: Any]],
                results.count > 0,
                let appStoreVersionString = results[0]["version"] as? String,
                let appStoreVersion = Float(appStoreVersionString)
                else {
                    return false
            }
            
            if appStoreVersion > version {
                return true
            }
            else {
                return false
            }
        }
    }
    
    static func getBMILevel(_ weight:Double) -> Int {
        let _weight:Double = weight
        let _height:Double = Double(Global.UserInfo!["height"]!)!
    
        let _bmi:Double = _weight / ((_height/100.0) * (_height/100.0))
        
        let bmi:Double = Double(String(format: "%.1f", arguments: [_bmi]))!
        if bmi <= 18.4 {
            return 4
        } else if bmi <= 22.9 {
            return 1
        } else if bmi <= 24.9 {
            return 2
        } else {
            return 3
        }
    }
    
    static func getBMILevelColor(_ weight:Double) -> UIColor {
        if Global.getBMILevel(weight) == 1 {
            return UIColor.init(hexString: "7FDC24")
        } else if Global.getBMILevel(weight) == 2 {
            return UIColor.init(hexString: "F19D43")
        } else {
            return UIColor.init(hexString: "F14360")
        }
        
        //CBCCCD
        //7FDC24
        //F19D43
        //F14360
    }
    
    static func loadUserInfo(result: @escaping ((Int)->Void)) {
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_information.asp"
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
                        if resultText == "OK" {
                            let _userInfo: [String:String] = [
                                "name": xml.OUTPUT.Record["name"].text ?? "",
                                "birthday": xml.OUTPUT.Record["birthday"].text ?? "",
                                "gender": xml.OUTPUT.Record["gender"].text ?? "",
                                "height": xml.OUTPUT.Record["height"].text ?? "",
                                "email": xml.OUTPUT.Record["email"].text ?? "",
                                
                                "weightFirst": xml.OUTPUT.Record["weightFirst"].text ?? "",
                                "weightEnd": xml.OUTPUT.Record["weightEnd"].text ?? "",
                                "joinDate": xml.OUTPUT.Record["joinDate"].text ?? "",
                                "RegDateHeight": xml.OUTPUT.Record["RegDateHeight"].text ?? "",
                                "RegDateWeight": xml.OUTPUT.Record["RegDateWeight"].text ?? "",
                                
                                "passwordChangeDate": xml.OUTPUT.Record["passwordChangeDate"].text ?? "",
                                "CareNursing": xml.OUTPUT.Record["CareNursing"].text ?? "",
                                "CareCancer": xml.OUTPUT.Record["CareCancer"].text ?? "",
                                "CareDiabetes": xml.OUTPUT.Record["CareDiabetes"].text ?? "",
                                "CareNursingDiagnosis": xml.OUTPUT.Record["CareNursingDiagnosis"].text ?? "",
                                
                                "CareNursingDiagnosisDementia": xml.OUTPUT.Record["CareNursingDiagnosisDementia"].text ?? "",
                                "CareNursingDiagnosisLongTermCare": xml.OUTPUT.Record["CareNursingDiagnosisLongTermCare"].text ?? "",
                                "CareCancerDiagnosis": xml.OUTPUT.Record["CareCancerDiagnosis"].text ?? "",
                                "CareDiabetesDiagnosis": xml.OUTPUT.Record["CareDiabetesDiagnosis"].text ?? "",
                            ]
                            
                            Global.UserInfo = _userInfo
                            
                            debugPrint(_userInfo)
                            
                            result(1)
                            
                        } else if resultText == "Error" {
                            result(2)
                        }
                    }
                } else {
                    result(3)
                }
        }
    }
    
    static func serverAddDevicePushKey() -> Bool {
        guard let userid = Global.userid else {
            return false
        }
        
        guard let token = Global.token else {
            return false
        }
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_devicePushKey.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": userid,
            "devicePushKey": token,
        ]
        
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseData { (response) in
                if let data = response.data {
                    debugPrint(data.toStringKr())
                }
        }
        
        return true
    }
}

// MARK: - Walking
extension Global {
    static let dispatchGroup = DispatchGroup()
    static let globalGroupWalking = DispatchGroup()
    
    static var pedometer = CMPedometer()
    
    class WalkRow {
        var key:String = "0"
        var steps:String = "0"
        var cal:String = "0.0"
        var distance:String = "0.0"
        var seconds:String = "0"
    }
    
//    이동거리(m) = ((키(cm) - 100)  * 걸음수)/100
//    마일당 칼로리(cal/mile) =  3.7103 + 0.2678*체중(kg) + (0.0359*(체중(kg)*60*0.0006213)*2)*체중(kg)
//    소비칼로리(cal) = 이동거리(m) * 마일당 칼로리(cal/mile) * 0.0006213
    static func toDayWalking() -> [WalkRow] {
        return Global.walking(Date())
    }
    
    static func walking(_ date:Date) -> [WalkRow] {
        let group = DispatchGroup()
        
        var dataSet:[WalkRow] = [WalkRow](repeating: WalkRow(), count: 24)
        
        for i in 0..<5 {
            if let startDate = Calendar.current.date(bySettingHour: i, minute: 0, second: 0, of: date),
                let endDate = startDate.addHour(1),
                let user = Global.UserInfo,
                let userWeightEnd = user["weightEnd"],
                let userHeight = user["height"],
                let _weight:Float = Float(userWeightEnd),
                let _height:Float = Float(userHeight) {
                
                group.enter()
                self.pedometer.queryPedometerData(from: startDate, to: endDate) { (data, error) in
                    if let data = data {
                        let numberOfSteps = data.numberOfSteps.intValue
                        let distance = data.distance!.floatValue
                        let tempCalMile = 3.7103 + 0.2678 * _weight + (0.0359 * (_weight * 60 * 0.0006213) * 2) * _weight
                        let cal = distance * tempCalMile * 0.0006213
                        let seconds = roundf(distance * (165.0 * 0.0037)) / 1.1
                        let _row = WalkRow()
                        _row.key = String(format: "%d", i + 1)
                        _row.steps = String(format: "%d", numberOfSteps)
                        _row.cal = String(format: "%.1f", cal)
                        _row.distance = String(format: "%.1f", distance)
                        _row.seconds = String(format: "%.0f", seconds)
                        dataSet[i] = _row
                    }
                    group.leave()
                }
            }
        }
        
        let result = group.wait(timeout: .distantFuture)
        debugPrint("walking complate sync result = \(result)")
        
        return dataSet
    }
    
    static func convertWalkingParameter(_ dataSet:[WalkRow]) -> String {
        var arr:[String] = []
        for row in dataSet {
            arr.append(row.key)
            arr.append(row.steps)
            arr.append(row.distance)
            arr.append(row.cal)
            arr.append(row.seconds)
        }
        let parameter = arr.joined(separator: "_")
        return parameter
    }
    
    
    static func serverAddWalking(date:Date, result: @escaping ((Int)->Void)) {
        guard let userid = Global.userid else {
            return result(99)
        }
        
        guard let ukey = Global.ukey else {
            return result(99)
        }
        
        let dataSet = self.walking(date)
        let record = self.convertWalkingParameter(dataSet)
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/set.record.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": userid,
            "ukey": ukey,
            "recordDate": date.toString("yyyy-MM-dd"),
            "record": record
        ]
        
        globalGroupWalking.enter()
        let request = Alamofire.request(_url,
                                        method: .post,
                                        parameters: _parameters,
                                        encoding: URLEncoding.default,
                                        headers: [:])
        request.validate()
        .responseData { (response) in
            if let data = response.data {
                debugPrint(data.toStringKr())
                let xml = XML.parse(data)
                if let resultText = xml.OUTPUT.Result.text {
                    if resultText == "OK" {
                        UserDefaults.standard.set(date.toString("yyyyMMdd"), forKey: DefineUserDefaults.walking.rawValue)
                        UserDefaults.standard.synchronize()
                        
                        result(1)
                        return
                    }
                }
                result(4)
            } else {
                result(2)
            }
            
            globalGroupWalking.leave()
        }
    }
}
