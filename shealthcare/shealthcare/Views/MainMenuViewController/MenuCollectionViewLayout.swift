//
//  MenuCollectionViewLayout.swift
//  shealthcare
//
//  Created by Nguyên Duy on 4/17/19.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import Foundation
import UIKit

class MenuCollectionViewLayout: UICollectionViewLayout {
    private var _layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()     // 1
    private var _columnsYoffset: [CGFloat]!                                       // 2
    private var _contentSize: CGSize!                                             // 3
    
    private(set) var totalItemsInSection = 0
    
    // 4
    var totalColumns = 0
    var interItemsSpacing: CGFloat = 8
    
    // 5
    var contentInsets: UIEdgeInsets {
        return collectionView!.contentInset
    }
    
    override var collectionViewContentSize: CGSize {
        return _contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesArray = [UICollectionViewLayoutAttributes]()
        
        for (_, layoutAttributes) in _layoutMap {
            if rect.intersects(layoutAttributes.frame) {
                layoutAttributesArray.append(layoutAttributes)
            }
        }
        
        return layoutAttributesArray
    }

    // 1
    func columnIndexForItemAt(indexPath: IndexPath) -> Int {
        return indexPath.item % totalColumns
    }
    
    // 2
    func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        return CGRect.zero
    }
    
    // 3
    func calculateItemsSize() {}
    
    override func prepare() {
        // 1
        _layoutMap.removeAll()
        _columnsYoffset = Array(repeating: 0, count: totalColumns)
        
        totalItemsInSection = collectionView!.numberOfItems(inSection: 0)
        
        // 2
        if totalItemsInSection > 0 && totalColumns > 0 {
            // 3
            self.calculateItemsSize()
            
            var itemIndex = 0
            var contentSizeHeight: CGFloat = 0
            
            // 4
            while itemIndex < totalItemsInSection {
                // 5
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let columnIndex = self.columnIndexForItemAt(indexPath: indexPath)
                
                // 6
                let attributeRect = calculateItemFrame(indexPath: indexPath, columnIndex: columnIndex, columnYoffset: _columnsYoffset[columnIndex])
                let targetLayoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                targetLayoutAttributes.frame = attributeRect
                
                // 7
                contentSizeHeight = max(attributeRect.maxY, contentSizeHeight)
                _columnsYoffset[columnIndex] = attributeRect.maxY + interItemsSpacing
                _layoutMap[indexPath] = targetLayoutAttributes
                
                itemIndex += 1
            }
            
            // 8
            _contentSize = CGSize(width: collectionView!.bounds.width - contentInsets.left - contentInsets.right,
                                  height: contentSizeHeight)
        }
    }
}
