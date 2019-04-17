//
//  TurtleNeckViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 20/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class TurtleNeckViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewHelpGuide: UIImageView!
    
    
    @IBOutlet weak var viewList1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList3HeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        picker.allowsEditing = false
//        picker.sourceType = .camera
//        picker.delegate = self
//        picker.modalTransitionStyle = UIModalPresentationCurrentContext
        
        
        self.viewList1HeightConstraint.constant = 0
        self.viewList2HeightConstraint.constant = 0
        self.viewList3HeightConstraint.constant = 0
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionMenuButton(_ sender: Any) {
        let mypageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageViewController") as! MypageViewController
        self.navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    @IBAction func actionHelpButton(_ sender: Any) {
        imageViewHelpGuide.isHidden = !imageViewHelpGuide.isHidden
    }
    
    @IBAction func actionCameraButton(_ sender: Any) {
        #if !targetEnvironment(simulator)
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera;
            picker.allowsEditing = false
            self.present(picker, animated: false, completion: nil)
        }
        #endif
    }
    
    // 리스트 메뉴
    @IBAction func actionListButton(_ sender: Any) {
        if self.viewList1HeightConstraint.constant == 0 {
            self.viewList1HeightConstraint.constant = 49
            self.viewList2HeightConstraint.constant = 49
            self.viewList3HeightConstraint.constant = 49
        } else {
            self.viewList1HeightConstraint.constant = 0
            self.viewList2HeightConstraint.constant = 0
            self.viewList3HeightConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // 예방가이드
    @IBAction func actionPreventionGuide(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.kind = "prevention_guide"
        self.navigationController?.pushViewController(webViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 고개를 들어요
    @IBAction func actionHeadUpButton(_ sender: Any) {
        let headUpViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "HeadUpViewController") as! HeadUpViewController
        self.navigationController?.pushViewController(headUpViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 거북목 측정
    @IBAction func actionTurtleNeckButton(_ sender: Any) {
        let turtleNeckViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckViewController") as! TurtleNeckViewController
        self.navigationController?.pushViewController(turtleNeckViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 측정 기록
    @IBAction func actionResultButton(_ sender: Any) {
        let turtleNeckResultViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckResultViewController") as! TurtleNeckResultViewController
        self.navigationController?.pushViewController(turtleNeckResultViewController, animated: true)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) {
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let turtleNeckPhotoViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckPhotoViewController") as! TurtleNeckPhotoViewController
            turtleNeckPhotoViewController.photoImage = image
            self.navigationController?.pushViewController(turtleNeckPhotoViewController, animated: false)
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var viewControllers = self.navigationController?.viewControllers
                if let _count = viewControllers?.count {
                    viewControllers?.remove(at: _count - 2)
                    self.navigationController?.viewControllers = viewControllers!
                }
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
