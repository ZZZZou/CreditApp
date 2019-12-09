//
//  CardListCollectionViewFlowLayout.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/26.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import UIKit

class CardListCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        guard let bounds = collectionView?.bounds  else { return }
        scrollDirection = .horizontal
        
        minimumLineSpacing = -20.0
        let cellWidth: CGFloat = 260
        itemSize = CGSize(width: cellWidth, height: 180)
        
        sectionInset = UIEdgeInsets(top: 0, left: (bounds.width-cellWidth)/2, bottom: 0, right: (bounds.width-cellWidth)/2)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard var attrs = super.layoutAttributesForElements(in: rect), let collectionView = collectionView else {
            return nil
        }
        
        attrs = attrs.map{$0.copy()} as! [UICollectionViewLayoutAttributes]
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width/2.0;
        for attributes in attrs {
            let distance = abs(attributes.center.x - centerX);
            var apartScale = distance / collectionView.bounds.width * 2;
            if apartScale > 1 { apartScale = 1}
//            let scale = abs(cos(apartScale * CGFloat.pi/4));
            let scale = (1 - apartScale * 0.2)
//            print(scale)
           
//            attributes.transform = CGAffineTransform(scaleX: scale, y: scale);
            
            let originRect = attributes.bounds
            attributes.bounds = CGRect(x: originRect.origin.x, y: originRect.origin.y, width: originRect.size.width*scale, height: originRect.size.height*scale)
            
            
        }
        return attrs;
        
    }
    
    //是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    

}
