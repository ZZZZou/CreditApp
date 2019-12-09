//
//  MeFeedbackImageModel.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/9.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import Photos
import Foundation

class MeFeedbackImageModel {
    var asset: PHAsset?
    var underlyingImage: UIImage?
    
    static func defaultImage() ->  MeFeedbackImageModel{
        let model = MeFeedbackImageModel()
        model.underlyingImage = UIImage(named: "gray-add")
        return model
    }
    
    func loadUnderlyingImage(completeHandle: @escaping (UIImage)->()) {
        guard let imgAsset = asset else {
            return
        }
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false;
        imageManager.requestImage(for: imgAsset, targetSize: UIScreen.size, contentMode: .aspectFit, options: options){ result, _ in
            if let resultImg = result {
                self.underlyingImage = resultImg
                completeHandle(resultImg)
            }
        }
            
    }
}
