//
//  TermPopupViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 04/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class TermPopupViewController: UIViewController {

    @IBOutlet weak var viewGuide: UIView!
    
    @IBOutlet weak var buttonAgree1: UIButton!
    @IBOutlet weak var buttonAgree2: UIButton!
    @IBOutlet weak var buttonAgree3: UIButton!
    @IBOutlet weak var buttonAgree4: UIButton!
    @IBOutlet weak var buttonAgree5: UIButton!
    
    @IBOutlet weak var buttonComplate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let scale = UIScreen.main.bounds.size.width / 320.0
        let trans = CGAffineTransform.init(scaleX: scale, y: scale)
        
        self.viewGuide.transform = trans
    }
    
    // MARK: - Action
    
    // 약관동의
    @IBAction func actionAgreeToggleButton(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        
        if buttonAgree1.isSelected
            && buttonAgree2.isSelected
            && buttonAgree3.isSelected
            && buttonAgree4.isSelected
            && buttonAgree5.isSelected {
            buttonComplate.isEnabled = true
        } else {
            buttonComplate.isEnabled = false
        }
    }
    
    //
    @IBAction func actionAgreeAllButton(_ sender: Any) {
        buttonAgree1.isSelected = true
        buttonAgree2.isSelected = true
        buttonAgree3.isSelected = true
        buttonAgree4.isSelected = true
        buttonAgree5.isSelected = true
        
        buttonComplate.isEnabled = true
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
