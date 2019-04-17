//
//  WeightGraphViewController.swift
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


class WeightGraphViewController: UIViewController {
    
    
    @IBOutlet weak var button4w: UIButton!
    @IBOutlet weak var button12w: UIButton!
    @IBOutlet weak var button1y: UIButton!
    @IBOutlet weak var viewSelected4w: UIView!
    @IBOutlet weak var viewSelected12w: UIView!
    @IBOutlet weak var viewSelected1y: UIView!
    
    @IBOutlet weak var viewWeightLeft: UIView!
    @IBOutlet weak var viewWeightRight: UIView!
    
    @IBOutlet weak var labelNowWeight: UILabel!
    @IBOutlet weak var labelNowBmi: UILabel!
    @IBOutlet weak var labelNowBmiUnit: UILabel!
    
    @IBOutlet weak var labelFirstWeight: UILabel!
    @IBOutlet weak var labelLossWeight: UILabel!
    @IBOutlet weak var labelLossWeightUnit: UILabel!
    
    @IBOutlet weak var viewGraphArea: UIView!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var labelFirstDay: UILabel!
    @IBOutlet weak var labelLastDay: UILabel!
    
    
    
    
    
    var arrDays:[String] = []
    var arrWeakup:[Double?] = []
    var arrSleep:[Double?] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if true {
            let font:UIFont = UIFont.systemFont(ofSize: 10.0)
            let superscript:UIFont = UIFont.systemFont(ofSize: 6.0)
            let attributedString = NSMutableAttributedString(string: "kg/m2", attributes: [NSAttributedString.Key.font : font])
            attributedString.setAttributes([NSAttributedString.Key.font: superscript,
                                            NSAttributedString.Key.baselineOffset: 5], range: NSRange(location: 4, length: 1))
            self.labelNowBmiUnit.attributedText = attributedString
        }
        if true {
            let font:UIFont = UIFont.systemFont(ofSize: 10.0)
            let superscript:UIFont = UIFont.systemFont(ofSize: 6.0)
            let attributedString = NSMutableAttributedString(string: "kg/m2", attributes: [NSAttributedString.Key.font : font])
            attributedString.setAttributes([NSAttributedString.Key.font: superscript,
                                            NSAttributedString.Key.baselineOffset: 5], range: NSRange(location: 4, length: 1))
            self.labelLossWeightUnit.attributedText = attributedString
        }
        
        
        // init Charts
        chartView.isUserInteractionEnabled = false
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        // Hide Legend Square
        chartView.legend.enabled = false
        
        // Remove xAxis Line
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        
        chartView.legend.form = .line
        
        chartView.chartDescription?.text = ""
        
        // 왼쪽 축.
        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.axisMaximum = 70
        chartView.leftAxis.axisMinimum = 40
        chartView.leftAxis.gridLineDashLengths = [10, 2]
        chartView.leftAxis.drawLimitLinesBehindDataEnabled = true
        
        // 오른쪽 축.
        chartView.rightAxis.enabled = false
        
        // x-axis line
        chartView.xAxis.gridColor = UIColor.clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.xAxis.labelTextColor = UIColor.clear
        chartView.xAxis.spaceMax = 0.5
        chartView.xAxis.spaceMin = 0.5

        
        
        // init 4주 선택.
        self.button4w.isSelected = true
        self.viewSelected4w.isHidden = false
        loadData()
        
        displayView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.displayChart()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewWeightLeft.layer.cornerRadius = self.viewWeightLeft.bounds.width / 2.0
        self.viewWeightRight.layer.cornerRadius = self.viewWeightRight.bounds.width / 2.0
    }
    
    // MARK: - Function
    func loadData() {
        var _kind = "4w"
        if self.button4w.isSelected {
            _kind = "4w"
        } else if self.button12w.isSelected {
            _kind = "12w"
        } else {
            _kind = "1y"
        }
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/weight_list.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": Global.userid ?? "",
            "ukey": Global.ukey ?? "",
            "kind": _kind,
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
                            self.labelFirstDay.isHidden = true
                            self.labelLastDay.isHidden = true
                            
                            // 초기화.
                            self.arrDays.removeAll()
                            self.arrWeakup.removeAll()
                            self.arrSleep.removeAll()
                            
                            
                            // 값 입력.
                            var _dicDay:[String:String] = [:]
                            var _dicRow:[String:[String:String]] = [:]
                            for item in xml.OUTPUT.Record.Item {
                                if let recDate = item.RecDate.text {
                                    _dicDay[recDate] = "true"
                                }
                                let row = [
                                    "seq":item.seq.text ?? "",
                                    "RecDate":item.RecDate.text ?? "",
                                    "RecTime":item.RecTime.text ?? "",
                                    "kind":item.kind.text ?? "",
                                    "Weight":item.Weight.text ?? "",
                                    ]
                                
                                _dicRow[row["RecDate"]!+row["kind"]!] = row
                            }
                            
                            self.arrDays = Array(_dicDay.keys).sorted(by: { $0 < $1 })
//
                            
                            for item in self.arrDays {
                                if let _row = _dicRow[item + "1"], let _weight = _row["Weight"] {
                                    self.arrWeakup.append(Double(_weight))
                                } else {
                                    self.arrWeakup.append(nil)
                                }
                                if let _row = _dicRow[item + "2"], let _weight = _row["Weight"] {
                                    self.arrSleep.append(Double(_weight))
                                } else {
                                    self.arrSleep.append(nil)
                                }
                            }
                            
                            if self.arrDays.count > 1 {
                                self.labelFirstDay.text = self.arrDays.first?.toDate("yyyyMMdd")?.toString("yy.MM.dd")
                                self.labelLastDay.text = self.arrDays.last?.toDate("yyyyMMdd")?.toString("yy.MM.dd")
                                self.labelFirstDay.isHidden = false
                                self.labelLastDay.isHidden = false
                            }
                            
                            
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
    
    func displayView() {
        if let userInfo = Global.UserInfo {
            
            let _weightFirst:Double = Double(userInfo["weightFirst"] ?? "0")!
            let _weightEnd:Double = Double(userInfo["weightEnd"] ?? "0")!
            let _height:Double = Double(userInfo["height"] ?? "0")!
            let _weight:Double = _weightEnd
            
            self.labelNowWeight.text = String(format: "%.1f", arguments: [_weight])
            
            let _bmi:Double = _weight / ((_height/100.0) * (_height/100.0))
            self.labelNowBmi.text = String(format: "%.1f", arguments: [_bmi])
            
            self.labelFirstWeight.text = String(format: "%.1f", arguments: [_weightFirst])
            
            self.labelLossWeight.text = String(format: "%.1f", arguments: [(_weight-_weightFirst)])
            
            self.viewWeightLeft.backgroundColor = Global.getBMILevelColor(_weight)
            self.viewWeightRight.backgroundColor = Global.getBMILevelColor(_weightFirst)
        }
    }
    
    func displayChart() {
        if let userInfo = Global.UserInfo {
            chartView.leftAxis.resetCustomAxisMax()
            chartView.leftAxis.resetCustomAxisMin()
            
            let _weightFirst:Double = Double(userInfo["weightFirst"] ?? "0")!
         
            // 처음체중.
            let ll1 = ChartLimitLine(limit: _weightFirst, label: String(format: "%.1f", arguments: [_weightFirst]))
            ll1.valueTextColor = UIColor.init(hexString: "6488E5")
            ll1.lineColor = UIColor.init(hexString: "6488E5")
            ll1.lineWidth = 4
            ll1.lineDashLengths = [10, 2]
            ll1.valueFont = .systemFont(ofSize: 10)
            chartView.leftAxis.addLimitLine(ll1)
        }
        

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        
        
        
        let dollars1 = self.arrWeakup
        let dollars2 = self.arrSleep
        let rows = self.arrDays
        
        
        
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals1Color : [NSUIColor] = []
        for i in 0..<rows.count{
            if let _data = dollars1[i] {
                yVals1.append(ChartDataEntry(x: Double(i), y: _data))
                yVals1Color.append(NSUIColor.clear)
//                if i == rows.count - 1 {
//                    yVals1Color.append(NSUIColor.red)
//                } else {
//                    yVals1Color.append(NSUIColor.clear)
//                }
            }
        }
        if yVals1Color.count > 0 {
            yVals1Color[yVals1Color.count - 1] = NSUIColor.red
        }
        
        let set1: LineChartDataSet = LineChartDataSet(entries: yVals1, label: "기상 후")
        set1.setColor(UIColor.red.withAlphaComponent(0.5))
        set1.valueFormatter = DefaultValueFormatter(formatter: formatter)
        set1.valueColors = yVals1Color
        set1.setCircleColor(UIColor.red)
        set1.lineWidth = 2.0
        set1.circleRadius = 4.0
        set1.fillColor = UIColor.red
        set1.axisDependency = .left
        set1.drawCirclesEnabled = false
    
        
        var yVals2 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals2Color : [NSUIColor] = []
        for i in 0..<rows.count{
            if let _data = dollars2[i] {
                yVals2.append(ChartDataEntry(x: Double(i), y: _data))
                yVals2Color.append(NSUIColor.clear)
//                if i == rows.count - 1 {
//                    yVals2Color.append(NSUIColor.green)
//                } else {
//                    yVals2Color.append(NSUIColor.clear)
//                }
            }
        }
        if yVals2Color.count > 0 {
            yVals2Color[yVals2Color.count - 1] = NSUIColor.green
        }
        
        let set2: LineChartDataSet = LineChartDataSet(entries: yVals2, label: "자기 전")
        set2.setColor(UIColor.green.withAlphaComponent(0.5))
        set2.valueFormatter = DefaultValueFormatter(formatter: formatter)
        set2.valueColors = yVals2Color
        set2.setCircleColor(UIColor.green)
        set2.lineWidth = 2.0
        set2.circleRadius = 4.0
        set2.fillColor = UIColor.green
        set2.drawCirclesEnabled = false
        
        let data = LineChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: 9))
        
        
        chartView.data = data
        
//        chartView.animate(xAxisDuration: 0.5)
        
    }
    
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionKindSelectedButton(_ sender: Any) {
        self.button4w.isSelected = false
        self.button12w.isSelected = false
        self.button1y.isSelected = false
        self.viewSelected4w.isHidden = true
        self.viewSelected12w.isHidden = true
        self.viewSelected1y.isHidden = true
        
        let _button = sender as! UIButton
        if _button === self.button4w {
            self.button4w.isSelected = true
            self.viewSelected4w.isHidden = false
        }
        if _button === self.button12w {
            self.button12w.isSelected = true
            self.viewSelected12w.isHidden = false
        }
        if _button === self.button1y {
            self.button1y.isSelected = true
            self.viewSelected1y.isHidden = false
        }
        
        displayChart()
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
