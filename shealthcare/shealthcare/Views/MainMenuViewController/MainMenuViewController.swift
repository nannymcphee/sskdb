//
//  MainMenuViewController.swift
//  shealthcare
//
//  Created by Nguyên Duy on 4/17/19.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import CollectionKit

class MainMenuViewController: UIViewController {
    //MARK: - ELEMENTS
    @IBOutlet weak var cvMenu: UICollectionView!
    @IBOutlet weak var vNavigation: UIView!
    
    
    //MARK: - VARIOUSES
    private let menuManager = MenuManager.shared()
    private let reuseId = "MainMenuCollectionViewCell"
    private let longPressGesture: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer()
        return gestureRecognizer
    }()
    
    private var menuItems: [MenuItem] = [
        MenuItem(name: "검진〮진료", imageName: "ic_menu01_medical"),
        MenuItem(name: "건강 컨텐츠", imageName: "ic_menu02_contents"),
        MenuItem(name: "헬스케어", imageName: "ic_menu10_call"),
        MenuItem(name: "통증 줄이기", imageName: "ic_menu04_vertebra"),
        MenuItem(name: "통증 예방하기", imageName: "ic_menu03_weight"),
        MenuItem(name: "경추 밸런스", imageName: "ic_menu09_emergency"),
        MenuItem(name: "응급포털", imageName: "ic_menu07_checkup"),
        MenuItem(name: "자가건강체크", imageName: "ic_menu08_magnifier"),
        MenuItem(name: "마이페이지", imageName: "ic_menu05_drug")
    ]
    
    //MARK: - OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupMenuCollectionView()
        setupLongPressGesture()
        getMenuItems()
    }

    //MARK: - ACTIONS
    @objc func handleLongPress(_ gesture: UIGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = cvMenu.indexPathForItem(at: gesture.location(in: cvMenu)) else {
                return
            }
            cvMenu.beginInteractiveMovementForItem(at: selectedIndexPath)
            startShakeAnimation()
        case .changed:
            cvMenu.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            cvMenu.endInteractiveMovement()
            stopShakeAnimation()
        default:
            cvMenu.cancelInteractiveMovement()
            stopShakeAnimation()
        }
    }
    
    //MARK: - FUNCTIONS
    func setupUI() {
        if Device.hasTopNotch {
            vNavigation.changeHeight(to: AppConstants.topBarHeight)
        }
    }
    
    func getMenuItems() {
        if let cachedItems = menuManager.getAll(), cachedItems.isEmpty == false {
            menuItems = cachedItems
            cvMenu.reloadData()
        } else {
            menuManager.save(menuItems)
        }
    }
    
    func setupMenuCollectionView() {
        cvMenu.delegate = self
        cvMenu.dataSource = self
        cvMenu.register(UINib(nibName: reuseId, bundle: nil), forCellWithReuseIdentifier: reuseId)
        
        if let flowLayout = self.cvMenu.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: AppConstants.screenWidth / 4 + 20, height: AppConstants.screenHeight / 4)
        }
    }
    
    func setupLongPressGesture() {
        longPressGesture.addTarget(self, action: #selector(handleLongPress))
        cvMenu.addGestureRecognizer(longPressGesture)
    }
    
    private func startShakeAnimation() {
        cvMenu.visibleCells.forEach { (cell) in
            if let cell = cell as? MainMenuCollectionViewCell {
                cell.startShakeAnimation()
            }
        }
    }
    
    private func stopShakeAnimation() {
        cvMenu.visibleCells.forEach { (cell) in
            if let cell = cell as? MainMenuCollectionViewCell {
                cell.stopShakeAnimation()
            }
        }
    }
}

//MARK: - EXTENSIONS
extension MainMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = menuItems[indexPath.item]
        print("Selected: \(item.name.orEmpty())")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? MainMenuCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = menuItems[indexPath.item]
        cell.populateData(item: item)
        return cell
    }
    
    // For drag & drop
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tmp = menuItems[sourceIndexPath.item]
        
        menuItems[sourceIndexPath.item] = menuItems[destinationIndexPath.item]
        menuItems[destinationIndexPath.item] = tmp
        menuManager.save(menuItems)

        cvMenu.reloadData()
    }
}
