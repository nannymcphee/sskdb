//
//  DrugMarkSelectViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 02/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class DrugMarkSelectViewController: UIViewController {

    public var resultCallback: ((String)->Void)? = nil
    
    public var defaultValue:String? = nil {
        didSet {
            if let _val = defaultValue {
                var isDefault = false
            }
        }
    }
    
    var selectedFileName:String? = nil
    
    @IBOutlet weak var buttonMark1: UIButton!
    @IBOutlet weak var buttonMark2: UIButton!
    @IBOutlet weak var buttonMark3: UIButton!
    @IBOutlet weak var buttonMark4: UIButton!
    @IBOutlet weak var buttonMark5: UIButton!
    @IBOutlet weak var buttonMark6: UIButton!
    @IBOutlet weak var buttonMark7: UIButton!
    @IBOutlet weak var buttonMark8: UIButton!
    @IBOutlet weak var buttonMark9: UIButton!
    
    
    @IBOutlet weak var buttonColorRed: UIButton!
    @IBOutlet weak var buttonColorScarlet: UIButton!
    @IBOutlet weak var buttonColorOrange: UIButton!
    @IBOutlet weak var buttonColorYellow: UIButton!
    @IBOutlet weak var buttonColorChartreuse: UIButton!
    @IBOutlet weak var buttonColorGreen: UIButton!
    @IBOutlet weak var buttonColorBlue: UIButton!
    @IBOutlet weak var buttonColorNavy: UIButton!
    
    var buttonColorArray = [UIButton]()
    var buttonMarkArray = [UIButton]()
    
    let imageIcon01 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon01")
    let imageIcon02 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon02")
    let imageIcon03 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon03")
    let imageIcon04 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon04")
    let imageIcon05 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon05")
    let imageIcon06 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon06")
    let imageIcon07 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon07")
    let imageIcon08 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon08")
    let imageIcon09 = UIImage.init(named: "ic_drug_input_icon_selet_color_icon09")
    
    let imageRed = UIImage.init(named: "ic_drug_input_icon_selet_color_red")
    let imageScarlet = UIImage.init(named: "ic_drug_input_icon_selet_color_scarlet")
    let imageOrange = UIImage.init(named: "ic_drug_input_icon_selet_color_orange")
    let imageYellow = UIImage.init(named: "ic_drug_input_icon_selet_color_yellow")
    let imageChartreuse = UIImage.init(named: "ic_drug_input_icon_selet_color_chartreuse")
    let imageGreen = UIImage.init(named: "ic_drug_input_icon_selet_color_green")
    let imageBlue = UIImage.init(named: "ic_drug_input_icon_selet_color_blue")
    let imageNavy = UIImage.init(named: "ic_drug_input_icon_selet_color_navy")
    
    let colors:[String] = ["red", "scarlet", "orange", "yellow", "chartreuse", "green", "blue", "navy"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buttonColorArray.append(buttonColorRed)
        buttonColorArray.append(buttonColorScarlet)
        buttonColorArray.append(buttonColorOrange)
        buttonColorArray.append(buttonColorYellow)
        buttonColorArray.append(buttonColorChartreuse)
        buttonColorArray.append(buttonColorGreen)
        buttonColorArray.append(buttonColorBlue)
        buttonColorArray.append(buttonColorNavy)
        
        buttonMarkArray.append(buttonMark1)
        buttonMarkArray.append(buttonMark2)
        buttonMarkArray.append(buttonMark3)
        buttonMarkArray.append(buttonMark4)
        buttonMarkArray.append(buttonMark5)
        buttonMarkArray.append(buttonMark6)
        buttonMarkArray.append(buttonMark7)
        buttonMarkArray.append(buttonMark8)
        buttonMarkArray.append(buttonMark9)
        
        for i in 0..<buttonColorArray.count {
            let button = buttonColorArray[i]
            button.tag = i
        }
        for i in 0..<buttonMarkArray.count {
            let button = buttonMarkArray[i]
            button.tag = i
        }
        
        let scale = UIScreen.main.bounds.size.width / 320.0
        
        buttonMark1.setImage(imageIcon01?.scale(scale: scale), for: .normal)
        buttonMark2.setImage(imageIcon02?.scale(scale: scale), for: .normal)
        buttonMark3.setImage(imageIcon03?.scale(scale: scale), for: .normal)
        buttonMark4.setImage(imageIcon04?.scale(scale: scale), for: .normal)
        buttonMark5.setImage(imageIcon05?.scale(scale: scale), for: .normal)
        buttonMark6.setImage(imageIcon06?.scale(scale: scale), for: .normal)
        buttonMark7.setImage(imageIcon07?.scale(scale: scale), for: .normal)
        buttonMark8.setImage(imageIcon08?.scale(scale: scale), for: .normal)
        buttonMark9.setImage(imageIcon09?.scale(scale: scale), for: .normal)
        
        buttonColorRed.setImage(imageRed?.scale(scale: scale), for: .normal)
        buttonColorScarlet.setImage(imageScarlet?.scale(scale: scale), for: .normal)
        buttonColorOrange.setImage(imageOrange?.scale(scale: scale), for: .normal)
        buttonColorYellow.setImage(imageYellow?.scale(scale: scale), for: .normal)
        buttonColorChartreuse.setImage(imageChartreuse?.scale(scale: scale), for: .normal)
        buttonColorGreen.setImage(imageGreen?.scale(scale: scale), for: .normal)
        buttonColorBlue.setImage(imageBlue?.scale(scale: scale), for: .normal)
        buttonColorNavy.setImage(imageNavy?.scale(scale: scale), for: .normal)
        
        buttonColorRed.isSelected = true
        buttonMark1.isSelected = true
        
        display()
    }
    
    
    // MARK: - IBAction
    @IBAction func actionCancelButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func actionComplateButton(_ sender: Any) {
        if selectedFileName == nil {
            return
        }
        
        if let cb = resultCallback, let selectedFileName = selectedFileName {
            cb(selectedFileName)
        }
        
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func actionMarkButton(_ sender: UIButton) {
        for i in 0..<buttonMarkArray.count {
            let button = buttonMarkArray[i]
            button.isSelected = false
        }
        sender.isSelected = true
        display()
    }
    
    @IBAction func actionColorButton(_ sender: UIButton) {
        for button in buttonColorArray {
            button.isSelected = false
        }
        sender.isSelected = true
        display()
    }
    
    func display() {
        var selectedColor:Int = -1
        var selectedMark:Int = -1
        for i in 0..<buttonColorArray.count {
            let button = buttonColorArray[i]
            button.imageView?.borderWidth = 0.0
            if button.isSelected {
                selectedColor = button.tag
                button.imageView?.borderWidth = 1.0
                button.imageView?.borderColor = UIColor.white
            }
        }
        for i in 0..<buttonMarkArray.count {
            let button = buttonMarkArray[i]
            if button.isSelected {
                selectedMark = button.tag
            }
        }
        
        let scale = UIScreen.main.bounds.size.width / 320.0
        
        buttonMark1.setImage(imageIcon01?.scale(scale: scale), for: .normal)
        buttonMark2.setImage(imageIcon02?.scale(scale: scale), for: .normal)
        buttonMark3.setImage(imageIcon03?.scale(scale: scale), for: .normal)
        buttonMark4.setImage(imageIcon04?.scale(scale: scale), for: .normal)
        buttonMark5.setImage(imageIcon05?.scale(scale: scale), for: .normal)
        buttonMark6.setImage(imageIcon06?.scale(scale: scale), for: .normal)
        buttonMark7.setImage(imageIcon07?.scale(scale: scale), for: .normal)
        buttonMark8.setImage(imageIcon08?.scale(scale: scale), for: .normal)
        buttonMark9.setImage(imageIcon09?.scale(scale: scale), for: .normal)
        
        if selectedColor > -1 && selectedMark > -1 {
            let fileName = String(format: "ic_drug_input_icon_selet_color_icon0%d_%@", selectedMark + 1, colors[selectedColor])
            
            let selectedMark = buttonMarkArray[selectedMark]
            let image = UIImage.init(named: fileName)
            selectedMark.setImage(image!.scale(scale: scale), for: .normal)
            
            selectedFileName = fileName
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
