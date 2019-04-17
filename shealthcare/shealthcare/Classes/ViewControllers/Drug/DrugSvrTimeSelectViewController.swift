//
//  DrugSvrTimeSelectViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 02/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

extension DrugSvrTimeSelectViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rows[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        resultString = rows[row]
    }
}

class DrugSvrTimeSelectViewController: UIViewController {
    var defaultValue: String? = nil
    
    public var resultCallback: ((String)->Void)? = nil

    @IBOutlet weak var pickerView: UIPickerView!
    
    var rows:[String] = []
    
    var resultString:String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        for i in 0..<10 {
            rows.append(String(format: "%d", i + 1))
        }
        
        if let defaultValue = defaultValue, let iValue = Int(defaultValue) {
            pickerView.selectRow(iValue - 1, inComponent: 0, animated: true)
            resultString = defaultValue
        }
    }
    

    // MARK: - IBAction
    @IBAction func actionCancelButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func actionComplateButton(_ sender: Any) {
        self.dismiss(animated: true) {
            if let cb = self.resultCallback {
                cb(self.resultString)
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
