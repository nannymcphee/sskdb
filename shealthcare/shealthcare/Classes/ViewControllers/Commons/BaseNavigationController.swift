//
//  BaseNavigationController.swift
//  shealthcare
//
//  Created by SangWooKim on 11/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.delegate = self;
        self.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizer?.delegate = self;
        
        
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        
//        let scale = UIScreen.main.bounds.size.width / 320.0
//        let trans = CGAffineTransform.init(scaleX: scale, y: scale)
//
//        self.view.transform = trans
    }
    
    // MARK: - Function
    override func popViewController(animated: Bool) -> UIViewController? {
        debugPrint("self.viewControllers.count = %f", self.viewControllers.count)
        return super.popViewController(animated: animated)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 0 {
            self.interactivePopGestureRecognizer?.isEnabled = true;
        } else {
            self.interactivePopGestureRecognizer?.isEnabled = false;
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
