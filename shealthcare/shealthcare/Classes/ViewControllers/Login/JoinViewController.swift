//
//  JoinViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 11/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

//import GoneVisible

class JoinViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    // 서비스 대상 확인
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var birthdayTextField: TextField!
    @IBOutlet weak var phoneTextField: TextField!
    
    @IBOutlet weak var gender1Button: UIButton!
    @IBOutlet weak var gender2Button: UIButton!
    
    @IBOutlet weak var agree1Button: UIButton!
    @IBOutlet weak var agree2Button: UIButton!
    @IBOutlet weak var agree3Button: UIButton!
    @IBOutlet weak var agree4Button: UIButton!
    @IBOutlet weak var agree5Button: UIButton!
    
    @IBOutlet weak var agreeAllButton: UIButton!
    
    // 탭
    @IBOutlet weak var viewStepGuideFst: UILabel!
    @IBOutlet weak var viewStepGuideSec: UILabel!
    
    @IBOutlet weak var viewStepFst: UIView!
    @IBOutlet weak var viewStepSec: UIView!
    
    
    @IBOutlet weak var buttonStepFst: UIButton!
    @IBOutlet weak var buttonStepSec: UIButton!
    
    
    // 서비스 가입 정보 입력
    @IBOutlet weak var useridLabel: UILabel!
    @IBOutlet weak var authNumTextField: TextField!
    @IBOutlet weak var authNumButton: UIButton!
    @IBOutlet weak var authNumConfirmButton: UIButton!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var passwordConfirmTextField: TextField!
    @IBOutlet weak var heightTextField: TextField!
    @IBOutlet weak var weightTextField: TextField!
    @IBOutlet weak var authNumCheckLabel: UILabel!
    @IBOutlet weak var passwordCheckLabel: UILabel!
    
    var authNum:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.viewStepSec.visibility = .gone
        self.authNumCheckLabel.isHidden = true
        
        self.heightTextField.tag = 101
    }
    
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Notification Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            
            debugPrint("duration = %f", duration)
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.passwordTextField.text == self.passwordConfirmTextField.text {
                self.passwordCheckLabel.isHidden = true
            } else {
                self.passwordCheckLabel.isHidden = false
            }
        }
        
        return true
    }
    
    
    // MARK: - Action
    // 남성,여성 체크
    @IBAction func actionGenderToggleButton(_ sender: Any) {
        self.gender1Button.isSelected = false
        self.gender2Button.isSelected = false
        
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
    }
    
    // 약관동의
    @IBAction func actionAgreeToggleButton(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        
        if self.agree1Button.isSelected
            && self.agree2Button.isSelected
            && self.agree3Button.isSelected
            && self.agree4Button.isSelected
            && self.agree5Button.isSelected {
            self.agreeAllButton.isSelected = true
        } else {
            self.agreeAllButton.isSelected = false
        }
    }
    
    // 전체동의
    @IBAction func actionAgreeAllButton(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        
        self.agree1Button.isSelected = button.isSelected
        self.agree2Button.isSelected = button.isSelected
        self.agree3Button.isSelected = button.isSelected
        self.agree4Button.isSelected = button.isSelected
        self.agree5Button.isSelected = button.isSelected
    }
    
    
    // 개인정보 수집 및 제공동의
    @IBAction func actionTermPersonal(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "personalCollect"
        webViewController.isMenuShow = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 민감정보 수집 및 제공동의
    @IBAction func actionTermSensitive3(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "sensitiveCollect"
        webViewController.isMenuShow = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 제3자 개인정보 제공 동의
    @IBAction func actionTermPersonal3(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "personal3"
        webViewController.isMenuShow = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 제3자 민감정보 제공 동의
    @IBAction func actionTermSensitiveCollect(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "sensitive3"
        webViewController.isMenuShow = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 헬스케어 서비스
    @IBAction func actionTermHealthcare(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "healthcare"
        webViewController.isMenuShow = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // 서비스 대상 확인 다음 버튼
    @IBAction func actionNextButton(_ sender: Any) {
        
        let _name = self.nameTextField.text!
        let _birthday = self.birthdayTextField.text!
        let _phone = self.phoneTextField.text!
        let _gender = self.gender1Button.isSelected ? "1" : "2"
        let _agreeAll = self.agreeAllButton.isSelected
        
        if _name.count == 0 {
            "이름을 입력해주세요.".alert(self)
            return
        }
        
        if _birthday.count == 0 {
            "생년월일을 입력해주세요.".alert(self)
            return
        }
        
        if _phone.count == 0 {
            "휴대폰번호를 입력해주세요.".alert(self)
            return
        }
        
        if !_agreeAll {
            "모든 약관 동의를 하셔야 합니다".alert(self)
            return
        }
        
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_join_check.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "name": _name.encodeUrlKr(),
            "birthday": _birthday,
            "phone": _phone,
            "gender": _gender
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
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            debugPrint("ok")
                            
                            self.useridLabel.text = self.phoneTextField.text
                            
                            self.view.endEditing(true)
                            
                            self.viewStepFst.visibility = .gone
                            self.viewStepSec.visibility = .visible
                            self.buttonStepFst.isHidden = true
                            
                            self.viewStepGuideFst.backgroundColor = UIColor.init(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1)
                            self.viewStepGuideSec.backgroundColor = UIColor.init(red: 122.0/255.0, green: 149.0/255.0, blue: 230.0/255.0, alpha: 1)
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self, buttonCompletion: { (alertAction) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
    }
    
    // 인증 번호 발송
    @IBAction func actionAuthNumButton(_ sender: Any) {
        
        let _name = self.nameTextField.text!
        let _phone = self.phoneTextField.text!
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_auth_sms_number.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "kind": "join",
            "name": _name.encodeUrlKr(),
            "phone": _phone
        ]
        
        debugPrint(_parameters)
        
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
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            debugPrint("ok = %@", xml.OUTPUT.Record.AuthNum.text)
                            if let _authNum = xml.OUTPUT.Record.AuthNum.text {
                                self.authNum = _authNum
                                self.authNumConfirmButton.isEnabled = true
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
    
    // 인증 번호 확인
    @IBAction func actionAuthNumConfirmButton(_ sender: Any) {
        let _authNum = self.authNumTextField.text!
        if self.authNum == _authNum {
            self.authNumTextField.isUserInteractionEnabled = false
            self.authNumConfirmButton.isHidden = true
            self.authNumCheckLabel.isHidden = false
        }
    }
    
    // 서비스 가입 정보 완료
    @IBAction func actionSuccessButton(_ sender: Any) {
        let _name = self.nameTextField.text!
        let _birthday = self.birthdayTextField.text!
        let _phone = self.phoneTextField.text!
        let _gender = self.gender1Button.isSelected ? "1" : "2"
        let _password = self.passwordTextField.text!
        let _height = self.heightTextField.text!
        let _weight = self.weightTextField.text!
        
        if self.authNumTextField.text!.count == 0 {
            "인증번호를 입력하세요.".alert(self)
            return
        }
        
        if !self.authNumConfirmButton.isHidden {
            "인증번호를 확인 하세요.".alert(self)
            return
        }
        
        if _password.count == 0 {
            "비밀번호를 입력하세요.".alert(self)
            return
        }
        
        if !_password.validatePassword() {
            "비밀번호는 영문/숫자 혼합 8~12자로 입력해주세요.".alert(self)
            return
        }

        if self.passwordTextField.text! != self.passwordConfirmTextField.text! {
            "비밀번호를 확인 하세요.".alert(self)
            return
        }
        
        if _height.count == 0 {
            "현재 키를 입력하세요.".alert(self)
            return
        }
        
        if _weight.count == 0 {
            "현재 체중을 입력하세요.".alert(self)
            return
        }
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_join_service.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "name": _name.encodeUrlKr(),
            "birthday": _birthday,
            "phone": _phone,
            "gender": _gender,
            "password": _password.sha256(),
            "height": _height,
            "weight": _weight,
            "email": "",
            "termsHealthCare": "1",
            "termsPersonalCollect": "1",
            "termsSensitiveCollect": "1",
            "termsPersonal3": "1",
            "termsSensitive3": "1",
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
                            "서비스 가입이 완료되었습니다.\n어제보다 건강한 하루 되세요!".alert(self, buttonCompletion: { (alertAction) in
                                self.navigationController?.popToRootViewController(animated: true)
                            })
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
