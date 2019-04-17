//
//  GuidePopupViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 04/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

extension GuidePopupViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(page)
    }
}

class GuidePopupViewController: UIViewController {
    
    @IBOutlet weak var constraintGuide_Width: NSLayoutConstraint!
    
    @IBOutlet weak var viewGuide: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewGuide1: UIView!
    @IBOutlet weak var viewGuide2: UIView!
    @IBOutlet weak var viewGuide3: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        constraintGuide_Width.constant = self.viewGuide1.frame.width
        
        let scale = UIScreen.main.bounds.size.width / 320.0
        let trans = CGAffineTransform.init(scaleX: scale, y: scale)

        self.viewGuide.transform = trans
        
        self.scrollView.delegate = self
        
        
    }
    
    // MARK: - Action
    @IBAction func actionPageControl(_ sender: Any) {
        let _pageControl:UIPageControl = sender as! UIPageControl
        let page = _pageControl.currentPage
        
        var frame = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func actionCloseButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: DefineUserDefaults.guidePopup.rawValue + UIApplication.shared.applicationBuild())
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionNext1Button(_ sender: Any) {
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * 1
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func actionNext2Button(_ sender: Any) {
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * 2
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func actionNext3Button(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
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
