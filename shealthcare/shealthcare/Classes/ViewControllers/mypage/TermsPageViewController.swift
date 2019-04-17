//
//  TermsPageViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 14/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class TermsPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // 헬스케어 서비스
    @IBAction func actionHealthcareButton(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "healthcare"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 개인정보 처리방침
    @IBAction func actionPersonalButton(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "personal"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 개인정보 수집 및 제공동의
    @IBAction func actionPersonalCollectButton(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "personalCollect"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 민감정보 수집 및 제공동의
    @IBAction func actionSensitiveCollectButton(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "sensitiveCollect"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // 제3자 개인정보 제공 동의
    @IBAction func actionPersonal3Button(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "personal3"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    // 제3자 민감정보 제공 동의
    @IBAction func actionSensitive3Button(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.userid = "ckdgpftmzpdjsa99"
        webViewController.ukey = "9999999999"
        webViewController.kind = "sensitive3"
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
