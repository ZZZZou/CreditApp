//
//  PhotoBrowerManager.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/9.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import MWPhotoBrowser
import UIKit

class PhotoBrowerManager: NSObject {
    var fromViewController: UIViewController!
    var allPhotos: [PHAsset] = []
    var selectedPhotos: [PHAsset] = []
    var selectedChangedHandle:(([PHAsset])->())!
    var startOnGrid = true
    
    var maxSelectCount = 4
    
    
    func pushToPhtoBrower(with startIndex: Int = 0) {
        // Create browser
        let photoBrower = MWPhotoBrowser(delegate: self)!
        photoBrower.displayActionButton = false;
        photoBrower.displayNavArrows = false
        photoBrower.displaySelectionButtons = true;
        photoBrower.alwaysShowControls = false
        photoBrower.zoomPhotosToFill = true
        photoBrower.enableGrid = true
        photoBrower.startOnGrid = startOnGrid
        
        photoBrower.setCurrentPhotoIndex(UInt(startIndex))
        fromViewController.navigationController?.pushViewController(photoBrower, animated: true)
    }
}

extension PhotoBrowerManager: MWPhotoBrowserDelegate {
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(allPhotos.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        let asset = allPhotos[Int(index)]
        return MWPhoto(asset: asset, targetSize: UIScreen.size)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, thumbPhotoAt index: UInt) -> MWPhotoProtocol! {
        let asset = allPhotos[Int(index)]
        return MWPhoto(asset: asset, targetSize: UIScreen.size)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, shouldSelectPhotoAt index: UInt) -> Bool {
        if selectedPhotos.count == maxSelectCount {
            MBProgressHUD .showMessage("最多选择\(maxSelectCount)张图片")
            return false
        }
        return true
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt, selectedChanged selected: Bool) {
        let asset = allPhotos[Int(index)]
        if selected {
            selectedPhotos.append(asset)
        }else{
            selectedPhotos.removeAll{ element in
                element == asset
            }
        }
        if let handle = selectedChangedHandle {
            handle(selectedPhotos)
        }
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, isPhotoSelectedAt index: UInt) -> Bool {
        let asset = allPhotos[Int(index)]
        return selectedPhotos.contains(asset)
    }
}
