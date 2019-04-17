//
//  DrugAddViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 21/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class DrugAddViewController: UIViewController {
    
    @IBOutlet weak var textFieldDrugName: UITextField!
    @IBOutlet weak var textFieldDose: UITextField!
    @IBOutlet weak var textFieldUnit: UITextField!
    @IBOutlet weak var textFieldMark: UITextField!
    @IBOutlet weak var imageViewMark: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    var defaultItem:Any? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageViewMark.isHidden = true
        
        if let defaultItem = defaultItem as? [String:Any] {
            self.nextButton.isEnabled = true
            
            self.textFieldDrugName.text = defaultItem["drugName"] as? String
            self.textFieldDose.text = defaultItem["dose"] as? String
            self.textFieldUnit.text = defaultItem["unit"] as? String
            self.textFieldMark.text = defaultItem["mark"] as? String
            
            self.textFieldMark.isHidden = true
            self.imageViewMark.isHidden = false
            let image = UIImage.init(named:defaultItem["mark"] as! String)
            self.imageViewMark.image = image!
        }
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionNextButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugSvrTimeViewController") as! DrugSvrTimeViewController
        vc.dataDrugName = self.textFieldDrugName.text
        vc.dataDose = self.textFieldDose.text
        vc.dataUnit = self.textFieldUnit.text
        vc.dataMark = self.textFieldMark.text
        if let defaultItem = defaultItem as? [String:Any] {
            vc.defaultKey = defaultItem["key"]
            vc.defaultTime = defaultItem["time"]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 약물명 선택.
    @IBAction func actionDrugNameSelectButton(_ sender: Any) {
        let drugNameSelectViewController = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugNameSelectViewController") as! DrugNameSelectViewController
        
        let vc = drugNameSelectViewController
        vc.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        vc.modalPresentationStyle = .overCurrentContext
        vc.resultCallback = { (result) in
            self.textFieldDrugName.text = result
            self.checkNext()
        }
        vc.defaultValue = self.textFieldDrugName.text!
        self.present(vc, animated: true, completion: nil)
    }
    
    // 투약량
    @IBAction func actionDoseButton(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "투약량", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.textFieldDose.text!
            textField.placeholder = "투약량"
            textField.keyboardType = .numberPad
        }
        let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
            self.textFieldDose.text = alert.textFields?[0].text
            self.checkNext()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 단위
    @IBAction func actionUnitButton(_ sender: Any) {
        let drugUnitSelectViewController = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugUnitSelectViewController") as! DrugUnitSelectViewController
        
        let vc = drugUnitSelectViewController
        vc.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        vc.modalPresentationStyle = .overCurrentContext
        vc.resultCallback = { (result) in
            self.textFieldUnit.text = result
            self.checkNext()
        }
        vc.defaultValue = self.textFieldUnit.text!
        self.present(vc, animated: true, completion: nil)
    }
    
    // 표기형
    @IBAction func actionMarkButton(_ sender: Any) {
        let drugMarkSelectViewController = UIStoryboard(name: "Drug", bundle: nil).instantiateViewController(withIdentifier: "DrugMarkSelectViewController") as! DrugMarkSelectViewController
        
        let vc = drugMarkSelectViewController
        vc.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        vc.modalPresentationStyle = .overCurrentContext
        vc.resultCallback = { (result) in
            self.textFieldMark.text = result
            self.textFieldMark.isHidden = true
            self.imageViewMark.isHidden = false
            
            let image = UIImage.init(named: result)
            self.imageViewMark.image = image!
            self.checkNext()
        }
        vc.defaultValue = self.textFieldUnit.text!
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - function
    func checkNext() {
        self.nextButton.isEnabled = false
        
        if self.textFieldDrugName.text!.count > 0 &&
            self.textFieldDose.text!.count > 0 &&
            self.textFieldUnit.text!.count > 0 &&
            self.textFieldMark.text!.count > 0 {
            self.nextButton.isEnabled = true
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
