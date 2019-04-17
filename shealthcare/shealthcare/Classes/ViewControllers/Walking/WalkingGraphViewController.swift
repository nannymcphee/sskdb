//
//  WalkingGraphViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 05/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

import HcdDateTimePicker

extension WalkingGraphViewController {
    func test1234(_ label:UILabel, _ keyword:String, _ color:UIColor) {
        
        let attributedString = NSMutableAttributedString(string: label.text!, attributes: [NSAttributedString.Key.font : label.font])
        attributedString.setAttributes([
            NSAttributedString.Key.foregroundColor: color],
                                       range: NSRange(label.text!.range(of: keyword)!, in: label.text!))
        label.attributedText = attributedString
    }
}

// MARK: - function Day
extension WalkingGraphViewController {
    func loadDataDay(_ date:Date) {
        let _url = "http://app.ichc.co.kr/api/shealthcare/get.statDay.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "stddate": date.toString("yyyy-MM-dd"),
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
                            self.date = date
                            self.resultData = xml.OUTPUT.Record
                            self.displayResultDay()
                            self.displayChart()
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    func displayResultDay() {
        self.labelDate.text = self.date.toString("yyyy.MM.dd (E)   ▼")
        if let label = self.view.viewWithTag(901) as? UILabel {
            label.text = "(시간)"
        }
        if let view = self.view.viewWithTag(1001) as? UILabel,
            let record = self.resultData {
            view.text = record.getText("TOTW", "0").comma
        }
        if let view = self.view.viewWithTag(1011),
            let record = self.resultData {
            let totw = record.getText("TOTW", "0")
            let targetWalking = record.getText("TargetWalking", "0")
            
            let percent:CGFloat = CGFloat(Int(totw)! / Int(targetWalking)!)
            
            let filteredConstraints = view.constraints.filter { $0.identifier == "width" }
            if let constraint = filteredConstraints.first {
                let newConstraint = constraint.constraintWithMultiplier(percent)
                view.removeConstraint(constraint)
                view.addConstraint(newConstraint)
                view.layoutIfNeeded()
            }
        }
        if let view = self.view.viewWithTag(1012) as? UIButton {
            
        }
        if let view = self.view.viewWithTag(1013) as? UILabel,
            let record = self.resultData {
            let totw = record.getText("TOTW", "0")
            let targetWalking = record.getText("TargetWalking", "0")
            let percent:CGFloat = CGFloat(Int(totw)! / Int(targetWalking)!)
            view.text = String(format: "%d%%", Int(percent))
        }
        if let view = self.view.viewWithTag(1014) as? UILabel,
            let record = self.resultData {
            view.text = String(format: "%@보/일", record.getText("TOTW", "0").comma)
        }
        if let view = self.view.viewWithTag(1021) as? UILabel,
            let record = self.resultData {
            var total:Float = 0.0
            for i in 0..<24 {
                let key = String(format: "C%d", i+1)
                total = total + Float(record.getText(key, "0"))!
            }
            view.text = String(format: "%.1f", total / 1000.0)
        }
        if let view = self.view.viewWithTag(1022) as? UILabel,
            let record = self.resultData {
            var total:Float = 0.0
            for i in 0..<24 {
                let key = String(format: "D%d", i+1)
                total = total + Float(record.getText(key, "0"))!
            }
            view.text = String(format: "%.1f", total)
        }
        if let view = self.view.viewWithTag(1023) as? UILabel,
            let record = self.resultData {
            var total:Float = 0.0
            for i in 0..<24 {
                let key = String(format: "T%d", i+1)
                total = total + Float(record.getText(key, "0"))!
            }
            view.text = walkingSecond(NSNumber(value: total))
        }
    }
}


// MARK: - function Week
extension WalkingGraphViewController {
    func loadDataWeek(_ date:Date) {
        let _url = "http://app.ichc.co.kr/api/shealthcare/get.statWeek.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "stddate": date.toString("yyyy-MM-dd"),
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
                            self.date = date
                            self.resultData = xml.OUTPUT.Record
                            self.displayResultWeek()
                            self.displayChart()
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    func displayResultWeek() {
        (self.view.viewWithTag(901) as! UILabel).text = "(일별)"
        if let record = self.resultData {
            let sDate = (record["Item"][0]["RecDate"].text!.toDate("yyyy-MM-dd")?.toString("yyyy.MM.dd"))!
            let eDate = (record["Item"][6]["RecDate"].text!.toDate("yyyy-MM-dd")?.toString("MM.dd"))!
            
            self.labelDate.text = String(format: "%@~%@   ▼", sDate, eDate)
            
            (self.view.viewWithTag(101) as! UILabel).text = "가장 많이 움직인 주"
            (self.view.viewWithTag(102) as! UILabel).text = String(format: "%@~%@",
                                                                   (record.getText("MaxDate").components(separatedBy: "~")[0].toDate("yyyy-MM-dd")?.toString("yyyy.MM.dd"))!,
                                                                   (record.getText("MaxDate").components(separatedBy: "~")[1].toDate("yyyy-MM-dd")?.toString("MM.dd"))!
            )
            (self.view.viewWithTag(103) as! UILabel).text = "가장 적게 움직인 주"
            (self.view.viewWithTag(104) as! UILabel).text = String(format: "%@~%@",
                                                                   (record.getText("MinDate").components(separatedBy: "~")[0].toDate("yyyy-MM-dd")?.toString("yyyy.MM.dd"))!,
                                                                   (record.getText("MinDate").components(separatedBy: "~")[1].toDate("yyyy-MM-dd")?.toString("MM.dd"))!
            )
            
            var step:Int = 0
            var cal:Float = 0
            var dist:Float = 0
            var seconds:Int = 0
            var count:Int = 0
            let cnt:Int = record["Item"].all!.count
            for i in 0..<cnt {
                step = step + record["Item"][i]["DayW"].text!.toInt()
                cal = cal + record["Item"][i]["DayC"].text!.toFloat()
                dist = dist + record["Item"][i]["DayD"].text!.toFloat()
                seconds = seconds + record["Item"][i]["DayT"].text!.toInt()
                count = count + record["Item"][i]["SuccessYN"].text!.toInt()
            }
            
            self.detailCommon("주", step, cal, dist, seconds, count, record)
        }
    }
}


// MARK: - function Month
extension WalkingGraphViewController {
    func loadDataMonth(_ date:Date) {
        let _url = "http://app.ichc.co.kr/api/shealthcare/get.statMonth.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "stdyear": date.toString("yyyy"),
            "stdmonth": date.toString("MM"),
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
                            self.date = date
                            self.resultData = xml.OUTPUT.Record
                            self.displayResultMonth()
                            self.displayChart()
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    func displayResultMonth() {
        (self.view.viewWithTag(901) as! UILabel).text = "(일별)"
        if let record = self.resultData {
            self.labelDate.text = self.date.toString("yyyy.MM   ▼")
            
            (self.view.viewWithTag(101) as! UILabel).text = "가장 많이 움직인 달"
            (self.view.viewWithTag(102) as! UILabel).text = record["MaxDate"].text!
            (self.view.viewWithTag(103) as! UILabel).text = "가장 적게 움직인 달"
            (self.view.viewWithTag(104) as! UILabel).text = record["MinDate"].text!
            
            var step:Int = 0
            var cal:Float = 0
            var dist:Float = 0
            var seconds:Int = 0
            var count:Int = 0
            let cnt:Int = record["Item"].all!.count
            for i in 0..<cnt {
                step = step + record["Item"][i]["DayW"].text!.toInt()
                cal = cal + record["Item"][i]["DayC"].text!.toFloat()
                dist = dist + record["Item"][i]["DayD"].text!.toFloat()
                seconds = seconds + record["Item"][i]["DayT"].text!.toInt()
                count = count + record["Item"][i]["SuccessYN"].text!.toInt()
            }
            
            self.detailCommon("달", step, cal, dist, seconds, count, record)
        }
    }
}

// MARK: - function Year
extension WalkingGraphViewController {
    func loadDataYear(_ date:Date) {
        let _url = "http://app.ichc.co.kr/api/shealthcare/get.stateYear.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "stdyear": date.toString("yyyy"),
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
                            self.date = date
                            self.resultData = xml.OUTPUT.Record
                            self.displayResultYear()
                            self.displayChart()
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    func displayResultYear() {
        (self.view.viewWithTag(901) as! UILabel).text = "(월별)"
        if let record = self.resultData {
            self.labelDate.text = self.date.toString("yyyy   ▼")
            
            (self.view.viewWithTag(101) as! UILabel).text = "가장 많이 움직인 년도"
            (self.view.viewWithTag(102) as! UILabel).text = record["MaxDate"].text!
            (self.view.viewWithTag(103) as! UILabel).text = "가장 적게 움직인 년도"
            (self.view.viewWithTag(104) as! UILabel).text = record["MinDate"].text!
            
            var step:Int = 0
            var cal:Float = 0
            var dist:Float = 0
            var seconds:Int = 0
            var count:Int = 0
            let cnt:Int = record["Item"].all!.count
            for i in 0..<cnt {
                step = step + record["Item"][i]["DayW"].text!.toInt()
                cal = cal + record["Item"][i]["DayC"].text!.toFloat()
                dist = dist + record["Item"][i]["DayD"].text!.toFloat()
                seconds = seconds + record["Item"][i]["DayT"].text!.toInt()
                count = count + record["Item"][i]["SuccessYN"].text!.toInt()
            }
            
            self.detailCommon("연도", step, cal, dist, seconds, count, record)
        }
    }
}

// MARK: - function
extension WalkingGraphViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.axisLabels[Int(value)]
    }
    
    func loadData(_ date:Date) {
        if self.buttonDay.isSelected {
            loadDataDay(date)
        }
        if self.buttonWeek.isSelected {
            loadDataWeek(date)
        }
        if self.buttonMonth.isSelected {
            loadDataMonth(date)
        }
        if self.buttonYear.isSelected {
            loadDataYear(date)
        }
    }
    
    
    func walkingSecond(_ distance:NSNumber) -> String {
        let seconds = roundf(distance.floatValue * (165.0 * 0.0037)) / 1.1
        let hour = Int(seconds / 3600.0)
        let min = Int(seconds.truncatingRemainder(dividingBy: 3600.0) / 60.0)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 3600.0).truncatingRemainder(dividingBy: 60.0))
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    func displayChart() {
        var datas:[Double] = []
        var labels:[String] = []
        
        if self.buttonDay.isSelected {
            if let record = self.resultData {
                for i in 0..<24 {
                    let key = String(format: "W%d", i+1)
                    datas.append(record[key].text!.toDouble())
                }
            }
            for i in 0..<24 {
                labels.append(String(format: "%d", i+1))
            }
        }
        if self.buttonWeek.isSelected {
            if let record = self.resultData {
                let cnt:Int = record["Item"].all!.count
                for i in 0..<cnt {
                    if self.buttonWalking.isSelected {
                        datas.append(record["Item"][i]["DayW"].text!.toDouble())
                    }
                    if self.buttonCal.isSelected {
                        datas.append(record["Item"][i]["DayC"].text!.toDouble())
                    }
                    if self.buttonDistince.isSelected {
                        datas.append(record["Item"][i]["DayD"].text!.toDouble() / 1000)
                    }
                    if self.buttonTime.isSelected {
                        datas.append(record["Item"][i]["DayT"].text!.toDouble() / 60)
                    }
                    labels.append((record["Item"][i]["RecDate"].text!.toDate("yyyy-MM-dd")?.toString("dd"))!)
                }
                labels[0] = (record["Item"][0]["RecDate"].text!.toDate("yyyy-MM-dd")?.toString("MM.dd"))!
            }
        }
        if self.buttonMonth.isSelected {
            if let record = self.resultData {
                let cnt:Int = record["Item"].all!.count
                for i in 0..<cnt {
                    if self.buttonWalking.isSelected {
                        datas.append(record["Item"][i]["DayW"].text!.toDouble())
                    }
                    if self.buttonCal.isSelected {
                        datas.append(record["Item"][i]["DayC"].text!.toDouble())
                    }
                    if self.buttonDistince.isSelected {
                        datas.append(record["Item"][i]["DayD"].text!.toDouble() / 1000)
                    }
                    if self.buttonTime.isSelected {
                        datas.append(record["Item"][i]["DayT"].text!.toDouble() / 60)
                    }
                    labels.append((record["Item"][i]["RecDate"].text!.toDate("yyyy-MM-dd")?.toString("dd"))!)
                }
                labels[0] = (record["Item"][0]["RecDate"].text!.toDate("yyyy-MM-dd")?.toString("MM.dd"))!
            }
        }
        if self.buttonYear.isSelected {
            if let record = self.resultData {
                let cnt:Int = record["Item"].all!.count
                for i in 0..<cnt {
                    if self.buttonWalking.isSelected {
                        datas.append(record["Item"][i]["DayW"].text!.toDouble())
                    }
                    if self.buttonCal.isSelected {
                        datas.append(record["Item"][i]["DayC"].text!.toDouble())
                    }
                    if self.buttonDistince.isSelected {
                        datas.append(record["Item"][i]["DayD"].text!.toDouble() / 1000)
                    }
                    if self.buttonTime.isSelected {
                        datas.append(record["Item"][i]["DayT"].text!.toDouble() / 60)
                    }
                    labels.append(record["Item"][i]["RecMonth"].text!)
                }
            }
        }
        
        let dollars1 = datas
        self.axisLabels = labels
        
        var yVals1 : [BarChartDataEntry] = [BarChartDataEntry]()
        for i in 0..<labels.count{
            let _data = dollars1[i]
            yVals1.append(BarChartDataEntry(x: Double(i), y: _data))
        }
        
        let set1 = BarChartDataSet(entries: yVals1, label: "")
        set1.drawIconsEnabled = false
        set1.colors = [UIColor.init(hexString: "7796E7")]
//        set1.barBorderColor = UIColor.init(hexString: "7796E7")
        
        chartView.xAxis.valueFormatter = self
        
        let data = BarChartData(dataSet: set1)
        data.setValueFont(UIFont.systemFont(ofSize: 0))
        
        self.chartView.data = data
    }
    
    func detailCommon(_ type:String, _ step:Int, _ cal:Float, _ dist:Float, _ seconds:Int, _ count:Int, _ record:XML.Accessor) {
        
        (self.view.viewWithTag(201) as! UILabel).text = step.toString().comma
        let stepGap = step - record["PreDayW"].text!.toInt()
        (self.view.viewWithTag(202) as! UILabel).text = "지난 " + type + " 대비 " + stepGap.toString().comma + " 걸음" + stepGap.upDown()
        (self.view.viewWithTag(202) as! UILabel).attrText(keyword: stepGap.toString().comma, color: UIColor.init(hexString: "7796E7"))
        
        let preDist = record["PreDayD"].text!.toFloat()
        let distGap = dist - preDist
        (self.view.viewWithTag(301) as! UILabel).text = (dist / 1000.0).toString(digits: 1)
        (self.view.viewWithTag(302) as! UILabel).text = "지난 " + type + " 대비 " + distGap.toString().comma + " km" + distGap.upDown()
        (self.view.viewWithTag(303) as! UILabel).text = (preDist / 1000.0).toString(digits: 1)
        (self.view.viewWithTag(302) as! UILabel).attrText(keyword: distGap.toString().comma, color: UIColor.init(hexString: "7796E7"))
        
        let preCal = record["PreDayC"].text!.toFloat()
        let calGap = cal - preCal
        (self.view.viewWithTag(401) as! UILabel).text = cal.toString(digits: 1)
        (self.view.viewWithTag(402) as! UILabel).text = "지난 " + type + " 대비 " + calGap.toString().comma + " kcal" + calGap.upDown()
        (self.view.viewWithTag(403) as! UILabel).text = preCal.toString(digits: 1)
        (self.view.viewWithTag(402) as! UILabel).attrText(keyword: calGap.toString().comma, color: UIColor.init(hexString: "7796E7"))
        
        let preTime = record["PreDayT"].text!.toInt()
        let timeGap = seconds - preTime
        (self.view.viewWithTag(501) as! UILabel).text = seconds.toTimeString()
        (self.view.viewWithTag(502) as! UILabel).text = "지난 " + type + " 대비 " + timeGap.toTimeString() + "" + timeGap.upDown()
        (self.view.viewWithTag(503) as! UILabel).text = preTime.toTimeString()
        (self.view.viewWithTag(502) as! UILabel).attrText(keyword: timeGap.toTimeString(), color: UIColor.init(hexString: "7796E7"))
        
        let preCount = record["PreSuccessYNCNT"].text!.toInt()
        let countGap = count - preCount
        (self.view.viewWithTag(601) as! UILabel).text = count.toString()
        (self.view.viewWithTag(602) as! UILabel).text = "지난 " + type + " 대비 " + countGap.toString() + " 회" + countGap.upDown()
        (self.view.viewWithTag(603) as! UILabel).text = preCount.toString()
        (self.view.viewWithTag(602) as! UILabel).attrText(keyword: countGap.toString(), color: UIColor.init(hexString: "7796E7"))
    }
}

extension WalkingGraphViewController {
    // MARK: - function
    func displayButton() {
        let selectedColor = UIColor.init(hexString: "7796E7")
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        self.scrollView.scrollRectToVisible(rect, animated: false)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.buttonDay.isSelected {
                self.viewDetailChart.visibility = .visible
                self.viewDetail.visibility = .gone
                self.viewDetailFst.visibility = .visible
                self.viewDetailSec.visibility = .gone
                self.buttonReport.visibility = .gone
                self.buttonReport.isSelected = false
            } else {
                self.viewDetailChart.visibility = .visible
                self.viewDetail.visibility = .visible
                self.viewDetailFst.visibility = .gone
                self.viewDetailSec.visibility = .gone
                self.buttonReport.visibility = .visible
                self.buttonReport.isSelected = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                //
                self.buttonDay.addBottomBorderWithColor(color: selectedColor!, width: self.buttonDay.isSelected ? 3.0 : 0.0)
                self.buttonWeek.addBottomBorderWithColor(color: selectedColor!, width: self.buttonWeek.isSelected ? 3.0 : 0.0)
                self.buttonMonth.addBottomBorderWithColor(color: selectedColor!, width: self.buttonMonth.isSelected ? 3.0 : 0.0)
                self.buttonYear.addBottomBorderWithColor(color: selectedColor!, width: self.buttonYear.isSelected ? 3.0 : 0.0)
                
                //
                self.buttonWalking.addBottomBorderWithColor(color: selectedColor!, width: self.buttonWalking.isSelected ? 3.0 : 0.0)
                self.buttonCal.addBottomBorderWithColor(color: selectedColor!, width: self.buttonCal.isSelected ? 3.0 : 0.0)
                self.buttonDistince.addBottomBorderWithColor(color: selectedColor!, width: self.buttonDistince.isSelected ? 3.0 : 0.0)
                self.buttonTime.addBottomBorderWithColor(color: selectedColor!, width: self.buttonTime.isSelected ? 3.0 : 0.0)
            }
            
            
            if self.buttonDay.isSelected {
                self.labelType.text = "걸음수(보)"
            } else {
                if self.buttonWalking.isSelected {
                    self.labelType.text = "걸음수(보)"
                } else if self.buttonCal.isSelected {
                    self.labelType.text = "칼로리(kcal)"
                } else if self.buttonDistince.isSelected {
                    self.labelType.text = "거리(km)"
                } else if self.buttonTime.isSelected {
                    self.labelType.text = "시가(분)"
                } else {
                    self.labelType.text = ""
                }
            }
            
        }
    }
}

class WalkingGraphViewController: UIViewController {
    
    @IBOutlet weak var buttonDay: UIButton!
    @IBOutlet weak var buttonWeek: UIButton!
    @IBOutlet weak var buttonMonth: UIButton!
    @IBOutlet weak var buttonYear: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelDate: UILabel!
    
    
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var buttonWalking: UIButton!
    @IBOutlet weak var buttonCal: UIButton!
    @IBOutlet weak var buttonDistince: UIButton!
    @IBOutlet weak var buttonTime: UIButton!
    
    
    @IBOutlet weak var labelType: UILabel!
    
    @IBOutlet weak var viewDetailChart: UIView!
    @IBOutlet weak var viewDetailFst: UIView!
    @IBOutlet weak var viewDetailSec: UIView!
    

    @IBOutlet weak var chartView: BarChartView!
    
    @IBOutlet weak var buttonReport: UIButton!
    
    
    
    var resultData:XML.Accessor?
    var resultTOTW:String = "0"
    var resultTargetWalking:String = "0"
    var resultStdDate:String = ""
    var axisLabels:[String] = []
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buttonDay.isSelected = true
        buttonWalking.isSelected = true
        
        // init Charts
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        
        chartView.isUserInteractionEnabled = false
        
        chartView.chartDescription?.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.maxVisibleCount = 24
        
        
        chartView.legend.horizontalAlignment = .left
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.orientation = .horizontal
        chartView.legend.drawInside = false
        chartView.legend.form = .none
        chartView.legend.formSize = 0
        chartView.legend.font = UIFont.systemFont(ofSize: 0)
        chartView.legend.xEntrySpace = 0
        
        chartView.chartDescription?.text = ""
        
        
        // 왼쪽 축.
        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 9)
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        chartView.leftAxis.labelPosition = .outsideChart
        chartView.leftAxis.spaceTop = 0.15
        chartView.leftAxis.axisMinimum = 0.0
        
        // 오른쪽 축.
        chartView.rightAxis.enabled = false
        
        
        
        // x-axis line
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12.0)
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.granularity = 1.0
        chartView.xAxis.labelCount = 12
        
        
        
        
        loadData(Date())
        displayButton()
        
        self.viewDetailChart.visibility = .visible
        self.viewDetailFst.visibility = .visible
        self.viewDetailSec.visibility = .gone
        self.buttonReport.visibility = .gone
        
    }
    
    // MARK: - Action
    @IBAction func actionDismissButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionDateButton(_ sender: UIButton) {
        self.buttonDay.isSelected = false
        self.buttonWeek.isSelected = false
        self.buttonMonth.isSelected = false
        self.buttonYear.isSelected = false
        
        sender.isSelected = true
        
        self.displayButton()
        
        self.loadData(self.date)
    }
    
    @IBAction func actionDetailButton(_ sender: UIButton) {
        self.buttonWalking.isSelected = false
        self.buttonCal.isSelected = false
        self.buttonDistince.isSelected = false
        self.buttonTime.isSelected = false
        
        sender.isSelected = true
        
        self.displayButton()
        
        self.displayChart()
    }
    
    @IBAction func actionPrevDateButton(_ sender: Any) {
        if self.buttonDay.isSelected {
            loadData(self.date.addDay(-1)!)
        }
        if self.buttonWeek.isSelected {
            loadData(self.date.addDay(-7)!)
        }
        if self.buttonMonth.isSelected {
            loadData(self.date.addMonth(-1)!)
        }
        if self.buttonYear.isSelected {
            loadData(self.date.addYear(-1)!)
        }
    }
    
    @IBAction func actionNextDateButton(_ sender: Any) {
        if self.buttonDay.isSelected {
            loadData(self.date.addDay(1)!)
        }
        if self.buttonWeek.isSelected {
            loadData(self.date.addDay(7)!)
        }
        if self.buttonMonth.isSelected {
            loadData(self.date.addMonth(1)!)
        }
        if self.buttonYear.isSelected {
            loadData(self.date.addYear(1)!)
        }
    }
    
    @IBAction func actionReportButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.viewDetailChart.visibility = .gone
            self.viewDetailSec.visibility = .visible
        } else {
            self.viewDetailChart.visibility = .visible
            self.viewDetailSec.visibility = .gone
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
