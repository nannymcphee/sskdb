//
//  NotiSettingViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 06/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class NotiSettingViewController: UIViewController {
    static func initStoryboard() -> NotiSettingViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotiSettingViewController") as! NotiSettingViewController
        return vc
    }

    @IBOutlet weak var switchNoti: UISwitch!
    @IBOutlet weak var switchSound: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switchNoti.isOn = Global.pushNoti
        switchSound.isOn = Global.soundNoti
        
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionNotiButton(_ sender: UISwitch) {
        sender.setOn(!sender.isOn, animated: true)
        Global.pushNoti = sender.isOn
        
        Global.drugResetNoti()
        Neat.active()
    }
    
    @IBAction func actionSoundButton(_ sender: UISwitch) {
        sender.setOn(!sender.isOn, animated: true)
        Global.soundNoti = sender.isOn
        
        Global.drugResetNoti()
        Neat.active()
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
