//
//  GuideViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 12/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var guideView1: UIView!
    @IBOutlet weak var guideView2: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        debugPrint("befter = %@", self.guideView2.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // your code here
            debugPrint("asyncAfter = %@", self.guideView2.frame)
        }
    }
    
    override func viewWillLayoutSubviews() {
        debugPrint("viewWillLayoutSubviews  = %@" , self.guideView2.frame)
        
//        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.guideView2.frame.width)
    }
    
    // MARK: - Action
    @IBAction func actionPageControl(_ sender: Any) {
        let _pageControl:UIPageControl = sender as! UIPageControl
        let page = _pageControl.currentPage
        
        var frame = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionNotLook(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: DefineUserDefaults.guidePopup.rawValue + UIApplication.shared.applicationBuild())
        
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let page = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        debugPrint("scrollViewDidScroll = %f", page)
        self.pageControl.currentPage = Int(page)
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
