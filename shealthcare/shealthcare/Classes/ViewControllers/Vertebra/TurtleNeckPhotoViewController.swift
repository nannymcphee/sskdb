//
//  TurtleNeckPhotoViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 20/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit


class TurtleNeckPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photoImage:UIImage! = nil
    
    @IBOutlet weak var degreeView: UIView!
    @IBOutlet weak var earView: UIView!
    @IBOutlet weak var shoulderView: UIView!
    @IBOutlet weak var headTopView: UIView!
    
    @IBOutlet weak var buttonRotate: UIButton!
    @IBOutlet weak var buttonReflection: UIButton!
    
    
    
    var curAngle:CGFloat = 0.0
    var shapeLayer2:CAShapeLayer? = nil
    

    @IBOutlet weak var imageViewPhoto: UIImageView!
    
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var labelResultTitle: UILabel!
    @IBOutlet weak var labelResultDesc: UILabel!
    
    
    @IBOutlet weak var viewListMenu: UIView!
    
    @IBOutlet weak var viewList1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList3HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewContents: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        
        let scale = UIScreen.main.bounds.size.width / 320.0
        
        self.earView.frame = CGRect.init(x: self.earView.frame.origin.x * scale,
                                         y: self.earView.frame.origin.y * scale,
                                         width: self.earView.frame.size.width,
                                         height: self.earView.frame.size.height)
        self.headTopView.frame = CGRect.init(x: self.headTopView.frame.origin.x * scale,
                                             y: self.headTopView.frame.origin.y * scale,
                                             width: self.headTopView.frame.size.width,
                                             height: self.headTopView.frame.size.height)
        self.shoulderView.frame = CGRect.init(x: self.shoulderView.frame.origin.x * scale,
                                              y: self.shoulderView.frame.origin.y * scale,
                                              width: self.shoulderView.frame.size.width,
                                              height: self.shoulderView.frame.size.height)
        
        
        
        
        photoImage = fixrotation(photoImage)
        imageViewPhoto.image = photoImage
        
        drawDegree(stoke: UIColor.init(hexString: "6488E5"), fill: UIColor.init(hexString: "6488E5", andAlpha: 0.6))
        
        
        if true {
            let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panWasRecognized))
            earView.addGestureRecognizer(gesture)
        }
        if true {
            let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panWasRecognized))
            shoulderView.addGestureRecognizer(gesture)
        }
        if true {
            let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panWasRecognized))
            headTopView.addGestureRecognizer(gesture)
        }
        
        
        self.viewList1HeightConstraint.constant = 0
        self.viewList2HeightConstraint.constant = 0
        self.viewList3HeightConstraint.constant = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            "알림|||포인트(점)을 이동시켜 사진에 맞추어 주세요\n\n① 귓구멍\n② 어깨 위쪽의 둥근 라인 중앙\n③ 몸의 수직선상으로 이동".alert(self)
        }
    }
    
    @objc func panWasRecognized(_ panner:UIPanGestureRecognizer) {
        let draggedView:UIView = panner.view!
        let offset:CGPoint = panner.translation(in: draggedView.superview)
        let center:CGPoint = draggedView.center
        draggedView.center = CGPoint(x: center.x + offset.x, y: center.y + offset.y)
        
        if draggedView.frame.minY < 0 {
            draggedView.frame = CGRect(x: draggedView.frame.minX,
                                       y: 0,
                                       width: draggedView.frame.width,
                                       height: draggedView.frame.height)
        }
        
        if draggedView.frame.maxY > degreeView.frame.height {
            draggedView.frame = CGRect(x: draggedView.frame.minX,
                                       y: degreeView.frame.height - draggedView.frame.height,
                                       width: draggedView.frame.width,
                                       height: draggedView.frame.height)
        }
        
        if draggedView.frame.minX < 0 {
            draggedView.frame = CGRect(x: 0,
                                       y: draggedView.frame.minY,
                                       width: draggedView.frame.width,
                                       height: draggedView.frame.height)
        }
        
        if draggedView.frame.maxX > degreeView.frame.width {
            draggedView.frame = CGRect(x: degreeView.frame.width -  draggedView.frame.width,
                                       y: draggedView.frame.minY,
                                       width: draggedView.frame.width,
                                       height: draggedView.frame.height)
        }
        
        
        panner.setTranslation(.zero, in: draggedView.superview)
        
        
        drawDegree(stoke: UIColor.init(hexString: "6488E5"), fill: UIColor.init(hexString: "6488E5", andAlpha: 0.6))
        
        
        
    }
    
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionMenuButton(_ sender: Any) {
        let mypageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageViewController") as! MypageViewController
        self.navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    // 다시 찍기
    @IBAction func actionReCameraButton(_ sender: Any) {
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
    
    // 결과보기
    @IBAction func actionNeckResultButton(_ sender: Any) {
        if curAngle > 100 {
            "정확한 결과를 위해 귀와 목의 위치를 확인해 주세요".alert(self)
        }
        
        self.drawDegree(stoke: UIColor.init(hexString: "FFC001"), fill: UIColor.init(hexString: "FFC001", andAlpha: 0.6))
        
        earView.isHidden = true
        shoulderView.isHidden = true
        headTopView.isHidden = true
        setResultView()
        
        buttonRotate.isHidden = true
        buttonReflection.isHidden = true
        
        
        let _item:[String:Any] = [
            "datetime": Date(),
            "record": curAngle
        ]
        if var _items = UserDefaults.standard.array(forKey: DefineUserDefaults.turtleNeckList.rawValue) {
            _items.append(_item)
            UserDefaults.standard.set(_items, forKey: DefineUserDefaults.turtleNeckList.rawValue)
        } else {
            UserDefaults.standard.set([_item], forKey: DefineUserDefaults.turtleNeckList.rawValue)
        }
    }
    
    // 회전.
    @IBAction func actionRotateImageButton(_ sender: Any) {
        photoImage = rotateImage90(photoImage)
        imageViewPhoto.image = photoImage
    }
    
    // 좌우 반전
    @IBAction func actionReflectionImageButton(_ sender: Any) {
        if photoImage.imageOrientation == .upMirrored {
            photoImage = UIImage(cgImage: photoImage.cgImage!,
                                 scale: photoImage.scale,
                                 orientation: UIImage.Orientation.up)
        } else {
            photoImage = UIImage(cgImage: photoImage.cgImage!,
                                 scale: photoImage.scale,
                                 orientation: UIImage.Orientation.upMirrored)
        }
        imageViewPhoto.image = photoImage
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
        
        //        UIView.animate(withDuration: 0.5, animations: {
        //            self.view.layoutIfNeeded()
        //        }) { (Bool) in
        //
        //        }
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
    
    
    // MARK: - Function
    func setResultView() {
        var x1:CGFloat = headTopView.center.x > earView.center.x ? headTopView.center.x : earView.center.x
        let x2:CGFloat = shoulderView.center.x
        let xposition:CGFloat = (x1 > x2 ? x1 - (abs(x1 - x2)/3.0) + (abs(x1 - x2) * 0.1) : x1 + (abs(x1 - x2)/3.0) + (abs(x1 - x2) * 0.1))
        let isRight:Bool = (UIScreen.main.bounds.size.width - xposition) > 70.0
        x1 = isRight ? x1 : (headTopView.center.x < earView.center.x ? headTopView.center.x : earView.center.x)
        var x:CGFloat = 0;
        if isRight {
            x = (x1 > x2 ? x2 + ((x1 - x2) * 0.33) : x1 + ((x2 - x1) * 0.33)) + 10.0;
        } else {
            x = (x1 > x2 ? x2 + ((x1 - x2) * 0.66) : x1 + ((x2 - x1) * 0.66)) - 75.0;
        }
        let y1:CGFloat = isRight ? (headTopView.center.x > earView.center.x ? headTopView.center.y : earView.center.y ) : (headTopView.center.x > earView.center.x ? earView.center.y : headTopView.center.y );
        let y2:CGFloat = shoulderView.center.y;
        let y:CGFloat = (y1 > y2 ? y1 : y2) - (abs(y1 - y2)/3.0) - 15.0;
        
        let lbl_degree:UILabel = UILabel.init(frame: CGRect(x: x, y: y, width: 60, height: 30))
        lbl_degree.tag = 99
        lbl_degree.text = String(format: "%d°", Int(curAngle))
        lbl_degree.backgroundColor = UIColor.init(hexString: "FFC001")
        lbl_degree.textColor = UIColor.white
        lbl_degree.font = UIFont.systemFont(ofSize: 23)
        lbl_degree.textAlignment = .center
        lbl_degree.clipsToBounds = true
        lbl_degree.layer.cornerRadius = 15.0
        degreeView.addSubview(lbl_degree)
        
        //
        let resultTitle = getResultTitle()
        let resultDesc = getResultDesc()
        
        labelResultTitle.text = resultTitle
        labelResultDesc.text = resultDesc
        
        resultView.isHidden = false
        viewListMenu.isHidden = false
    }
    
    func getResultTitle() -> String {
        if curAngle > 60 {
            return "거북목"
        } else if curAngle >= 45 {
            return "척추전만등"
        } else if curAngle >= 30 {
            return "편평등"
        } else if curAngle >= 15 {
            return "척추후만등"
        }
        return "정상"
    }
    
    func getResultDesc() -> String {
        if curAngle > 60 {
            return "거북목 정렬의 체형 변형이 의심됩니다."
        } else if curAngle >= 45 {
            return "척추전만증 정렬의 체형 변형이 의심됩니다."
        } else if curAngle >= 30 {
            return "편평등 정렬의 체형 변형이 의심됩니다."
        } else if curAngle >= 15 {
            return "척추후만증 정렬의 체형 변형이 의심됩니다."
        }
        return "이상적 정렬의 자세를 보입니다."
    }
    
    func rotateImage90(_ img: UIImage) -> UIImage {
        if let imgRef = img.cgImage {
            let width: CGFloat = CGFloat(imgRef.width)
            let height: CGFloat = CGFloat(imgRef.height)
            var bounds = CGRect(x: 0, y: 0, width: width, height: height)
            var boundHeight: CGFloat = 0.0
            
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bytesPerPixel: Int = 4
            let bytesPerRow: Int = bytesPerPixel * Int(bounds.size.width)
            let bitsPerComponent: Int = 8
            if let context = CGContext(data: nil, width: Int(bounds.size.width), height: Int(bounds.size.height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) {
             
                context.rotate(by: ((.pi * 270) / 180))
                context.translateBy(x: -width, y: 0)
                context.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height))
                if let newImage = context.makeImage() {
                    let imageCopy = UIImage(cgImage: newImage)
                    
                    return imageCopy
                }
            }
        }
        
        return img
    }
    
    func fixrotation(_ image:UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        var transform: CGAffineTransform = .identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -(.pi / 2))
        case .up, .upMirrored:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        if let ctx = CGContext(data: nil,
                                   width: Int(image.size.width),
                                   height: Int(image.size.height),
                                   bitsPerComponent: (image.cgImage?.bitsPerComponent)!,
                                   bytesPerRow: 0,
                                   space: (image.cgImage?.colorSpace)!,
                                   bitmapInfo: (image.cgImage?.bitmapInfo)!.rawValue) {
            
            
            ctx.concatenate(transform)
            switch image.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
            default:
                ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
            
            if let cgimg = ctx.makeImage() {
                let img = UIImage(cgImage: cgimg)
                
                return img
            }
        }
        
        return image
    }
    
    func drawDegree(stoke:UIColor, fill:UIColor) {
        let shapeLayer = CAShapeLayer.init()
        let path = UIBezierPath.init()
        
        path.move(to: earView.center)
        path.addLine(to: shoulderView.center)
        path.move(to: shoulderView.center)
        path.addLine(to: headTopView.center)
        
        path.move(to: shoulderView.center)
        
        let w1 = abs(earView.center.x) - abs(shoulderView.center.y)
        let h1 = abs(earView.center.y) - abs(shoulderView.center.y)
        
        let w2 = abs(headTopView.center.x) - abs(shoulderView.center.x)
        let h2 = abs(headTopView.center.y) - abs(shoulderView.center.y)
        
        let diagonalLength1 = sqrt(pow(w1, 2) + pow(h1, 2))
        let diagonalLength2 = sqrt(pow(w2, 2) + pow(h2, 2))
        
        let radius = diagonalLength1 <= diagonalLength2 ? diagonalLength1 / 2 : diagonalLength2 / 2
        
        let clockwise = earView.center.x < headTopView.center.x
        
        var sAngle:CGFloat = 0.0
        if earView.center.y < shoulderView.center.y {
            sAngle = Meas_Angle(P1: earView.center, P2: shoulderView.center, P3: CGPoint(x: shoulderView.center.x + 100, y: shoulderView.center.y)) * -1
        } else {
            sAngle = (360 - abs(Meas_Angle(P1: earView.center, P2: shoulderView.center, P3: CGPoint(x: shoulderView.center.x + 100, y: shoulderView.center.y)))) * -1
        }
        
        var eAngle:CGFloat = 0.0
        if headTopView.center.y < shoulderView.center.y {
            eAngle = Meas_Angle(P1: headTopView.center, P2: shoulderView.center, P3: CGPoint(x: shoulderView.center.x + 100, y: shoulderView.center.y)) * -1
        } else {
            eAngle = (360 - abs(Meas_Angle(P1: headTopView.center, P2: shoulderView.center, P3: CGPoint(x: shoulderView.center.x + 100, y: shoulderView.center.y)))) * -1
        }
        
        curAngle = Meas_Angle(P1: earView.center, P2: shoulderView.center, P3: headTopView.center)
        
        path.addArc(withCenter: shoulderView.center, radius: radius, startAngle: sAngle.degreesToRadians, endAngle: eAngle.degreesToRadians, clockwise: clockwise)
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = stoke.cgColor
        shapeLayer.fillColor = fill.cgColor
        shapeLayer.lineWidth = 2
        
        if shapeLayer2 == nil {
            degreeView.layer.addSublayer(shapeLayer)
        } else {
            degreeView.layer.replaceSublayer(shapeLayer2!, with: shapeLayer)
        }
        
        
        shapeLayer2 = shapeLayer
        
        
        
        
        
        
    }
    
    func Meas_Angle(P1:CGPoint, P2:CGPoint, P3:CGPoint) -> CGFloat {
        var a:CGFloat, b:CGFloat, c:CGFloat, temp:CGFloat, Angle:CGFloat
        
        a = sqrt(pow(P1.x - P3.x, 2) + pow(P1.y - P3.y, 2))
        b = sqrt(pow(P1.x - P2.x, 2) + pow(P1.y - P2.y, 2))
        c = sqrt(pow(P2.x - P3.x, 2) + pow(P2.y - P3.y, 2))
        
        temp = (pow(b,2) + pow(c,2) - pow(a,2)) / (2*b*c)
        
        Angle = acos(temp) * (180 / .pi)
        
        return Angle
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.photoImage = self.fixrotation(image)
                self.imageViewPhoto.image = self.photoImage
                
                self.drawDegree(stoke: UIColor.init(hexString: "6488E5"), fill: UIColor.init(hexString: "6488E5", andAlpha: 0.6))
                
                let _lbl = self.degreeView.viewWithTag(99)
                _lbl?.removeFromSuperview()
                
                self.earView.isHidden = false
                self.shoulderView.isHidden = false
                self.headTopView.isHidden = false
                
                self.buttonRotate.isHidden = false
                self.buttonReflection.isHidden = false
                
                self.resultView.isHidden = true
                self.viewListMenu.isHidden = true
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
