//
//  PasswordChangeViewController.swift
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

class PasswordChangeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var nowPasswordTextField: TextField!
    @IBOutlet weak var newPasswordTextField: TextField!
    @IBOutlet weak var newPasswordConfirmTextField: TextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 비밀번호 변경
    @IBAction func actionChangeButton(_ sender: Any) {
        
        let _oldPwd = self.nowPasswordTextField.text!
        let _newPwd = self.newPasswordTextField.text!
        let _newPwdConfirmPwd = self.newPasswordConfirmTextField.text!
        
        if _oldPwd.count == 0 {
            "현재 비밀번호를 입력하세요.".alert(self)
            return
        }
        
        if _newPwd.count == 0 {
            "새 비밀번호를 입력하세요.".alert(self)
            return
        }
        
        if _newPwdConfirmPwd.count == 0 {
            "새 비밀번호 재입력을 입력하세요.".alert(self)
            return
        }
        
        if !_newPwd.validatePassword() {
            "새 비밀번호를 영문/숫자 혼합 8~12자로 입력해주세요.".alert(self)
            return
        }
        
        if _newPwd != _newPwdConfirmPwd {
            "새로 입력한 비밀번호가 다릅니다.".alert(self)
            return
        }
        
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_password_chang.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "ukey": Global.ukey ?? "",
            "userid": Global.userid ?? "",
            "oldPwd": _oldPwd.sha256(),
            "newPwd": _newPwd.sha256(),
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
                            _userInfo["passwordChangeDate"] = Date().toString("yyyyMMdd")
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
