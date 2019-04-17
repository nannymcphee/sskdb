//
//  MypageEditViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 14/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

class MypageEditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var useridLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gender1Button: UIButton!
    @IBOutlet weak var gender2Button: UIButton!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var heightTextField: TextField!
    @IBOutlet weak var passwordChangeDateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.heightTextField.tag = 101
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        displayUserInfo()
    }
    
    // MARK: - Function
    func displayUserInfo() {

        self.useridLabel.text = Global.userid
        self.nameLabel.text = Global.UserInfo!["name"]!
        self.gender1Button.isSelected = Global.UserInfo!["gender"]! == "1" ? true : false
        self.gender2Button.isSelected = Global.UserInfo!["gender"]! == "2" ? true : false
        self.birthdayLabel.text = Global.UserInfo!["birthday"]!.toDate("yyyyMMdd")?.toString("yyyy-MM-dd")
        self.heightTextField.text = Global.UserInfo!["height"]!
        self.passwordChangeDateLabel.text = "최근변경일 : \(Global.UserInfo!["passwordChangeDate"]!.toDate("yyyyMMdd")?.toString("yyyy-MM-dd") ?? "")"
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
        
        return true
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // 개인 정보 변경 (키)
    @IBAction func actionComplateButton(_ sender: Any) {
        let _height = self.heightTextField.text!
        if _height.count == 0 {
            "현재 키를 입력하세요.".alert(self)
            return
        }
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_height_chang.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "ukey": Global.ukey ?? "",
            "userid": Global.userid ?? "",
            "height": _height
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
                    
                    debugPrint(data.toStringKr())
                    
                    let xml = XML.parse(data)
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            var _userInfo:[String:String] = Global.UserInfo!
                            _userInfo["height"] = _height
                            Global.UserInfo = _userInfo
                            self.navigationController?.popViewController(animated: true)
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    // 비밀번호 변경
    @IBAction func actionPasswordChangeButton(_ sender: Any) {
        let passwordChangeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PasswordChangeViewController") as! PasswordChangeViewController
        self.navigationController?.pushViewController(passwordChangeViewController, animated: true)
    }
    
    // 회원 탈퇴
    @IBAction func actionWithdrawalButton(_ sender: Any) {
        let withdrawalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WithdrawalViewController") as! WithdrawalViewController
        self.navigationController?.pushViewController(withdrawalViewController, animated: true)
    }
    
    // 약관
    @IBAction func actionTermsPageButton(_ sender: Any) {
        let termsPageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermsPageViewController") as! TermsPageViewController
        self.navigationController?.pushViewController(termsPageViewController, animated: true)
    }
    
    // 로그아웃
    @IBAction func actionLogoutButton(_ sender: Any) {
        "로그아웃 하시겠습니까?".alert(self, buttonCompletion: { (alert) in
            let mainViewController:MainViewController = self.navigationController?.viewControllers[0] as! MainViewController
            mainViewController.loginViewControllerShow()
        }) { (alert) in
            
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
