//
//  WithdrawalViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 14/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class WithdrawalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionTelButton(_ sender: Any) {
        let tel = "tel://1670-0134"
        if let url = URL.init(string: tel),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
