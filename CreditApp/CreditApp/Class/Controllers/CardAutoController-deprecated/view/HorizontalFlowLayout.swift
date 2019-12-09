//
//  HorizontalFlowLayout.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/10/24.
//  Copyright © 2018 hujuun. All rights reserved.
//

import Foundation

class HorizontalFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment:CGFloat = 10000.0
        let centerX = proposedContentOffset.x + (collectionView?.bounds.size.width ?? kWidth) / 2
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView?.bounds.width ?? kWidth, height: collectionView?.bounds.height ?? 180)
        
        let arr = layoutAttributesForElements(in: targetRect) ?? []
        for layoutAttr in arr {
            let itemCenterX = layoutAttr.center.x
            if abs(itemCenterX - centerX) < abs(offsetAdjustment) {
                offsetAdjustment = itemCenterX - centerX
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    
}
