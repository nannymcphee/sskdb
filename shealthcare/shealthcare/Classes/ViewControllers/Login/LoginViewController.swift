//
//  LoginViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 11/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

extension Notification.Name {
    public static let loginSuccess = Notification.Name("loginSuccess")
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var useridTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    
    @IBOutlet weak var useridButton: UIButton!
    @IBOutlet weak var autoLoginButton: UIButton!
    
    @IBOutlet weak var labelBuildVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.labelBuildVersion.text = ""
        self.labelBuildVersion.addLongPress(3.0, { (gesture) in
            if gesture.state == .began {
                self.labelBuildVersion.text = UIApplication.shared.versionBuild()
            } else if gesture.state == .ended {
                self.labelBuildVersion.text = ""
            }
        })
        debugPrint("self.labelBuildVersion.gestureRecognizers?.count = \(self.labelBuildVersion.gestureRecognizers?.count)") 
        
        // 가이드 팝업 초기화
        UserDefaults.standard.set(false, forKey: DefineUserDefaults.guidePopup.rawValue + UIApplication.shared.applicationBuild())
        
        
        let _useridOn = UserDefaults.standard.bool(forKey: DefineUserDefaults.useridOn.rawValue)
        if _useridOn == true {
            self.useridButton.isSelected = true
            if let _userid = UserDefaults.standard.string(forKey: DefineUserDefaults.userid.rawValue) {
                self.useridTextField.text = _userid
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    @IBAction func actionUserIdButton(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
    }
    
    @IBAction func actionAutoLoginButton(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        let _userid = self.useridTextField.text!
        let _password = self.passwordTextField.text!
        
        if _userid.count == 0 {
            "아이디를 입력해주세요.".alert(self)
            return
        }
        
        if _password.count == 0 {
            "패스워드를 입력해주세요.".alert(self)
            return
        }
        
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_login.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "userid": _userid,
            "password": _password.sha256()
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
                            
                            if let ukey = xml.OUTPUT.Record.ukey.text {
                                UserDefaults.standard.set(self.useridButton.isSelected, forKey: DefineUserDefaults.useridOn.rawValue)
                                UserDefaults.standard.set(self.autoLoginButton.isSelected, forKey: DefineUserDefaults.autoLoginOn.rawValue)
                                
                                Global.userid = _userid
                                Global.ukey = ukey
                                
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: .loginSuccess, object:self)
                                }
//                                self.dismiss(animated: false, completion: nil)
                            }
                            
                            
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
