//
//  MeFeedbackViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/8.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import Action
import Photos
import RxSwift
import RxCocoa
import Foundation

class MeFeedbackViewModel {
    let provider: Networking
    let coordinator: SceneCoordinator
    let bag = DisposeBag()
    
    fileprivate let photoBrowerManager: PhotoBrowerManager!
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator) {
        self.provider = provider
        self.coordinator = coordinator
        
        photoBrowerManager = PhotoBrowerManager()
        photoBrowerManager.fromViewController = coordinator.currentViewController
        photoBrowerManager.selectedChangedHandle = {[unowned self] selectedAssets in
            self._selectedImageAssets.accept(selectedAssets)
        }
    }
    
    fileprivate var allPhotos: [PHAsset] = []
    
    fileprivate let _selectedImageAssets = BehaviorRelay<[PHAsset]>(value: [])
    var selectedImageModels: Observable<[MeFeedbackImageModel]> {
        return _selectedImageAssets
            .map{ origin in
                let models = origin.map{ asset -> MeFeedbackImageModel in
                    let model = MeFeedbackImageModel()
                    model.asset = asset
                    return model
                }
                if models.count != 4 {
                    return models + [.defaultImage()]
                }
                return models
            }
    }
    
    let imageLoadingCompleted = PublishRelay<Void>()
    
    
    
    func didSelectItem(at index: Int) -> CocoaAction{
        return CocoaAction{
            if self.isAddAction(with: index) {
                self.addImageAction()
            }else{
                self.editImageAction(at: index)
            }
            
            return self.imageLoadingCompleted
                .asObservable()
                .take(1)
        }
    }
    
    fileprivate func isAddAction(with index: Int) -> Bool {
        let count = _selectedImageAssets.value.count
        return (count == 0) || (count != 4 && count == index)
    }
    
    fileprivate func addImageAction() {
        loadAssets { completed in
            DispatchQueue.main.async {
                self.imageLoadingCompleted.accept(())
                if completed {
                    self.photoBrowerManager.allPhotos = self.allPhotos
                    self.photoBrowerManager.selectedPhotos = self._selectedImageAssets.value
                    self.photoBrowerManager.pushToPhtoBrower()
                }
            }
            
        }
    }
    
    fileprivate func editImageAction(at index: Int) {
        
        DispatchQueue.main.async {
            self.imageLoadingCompleted.accept(())
        }
        
        self.photoBrowerManager.allPhotos = self._selectedImageAssets.value
        self.photoBrowerManager.selectedPhotos = self._selectedImageAssets.value
        self.photoBrowerManager.startOnGrid = false
        self.photoBrowerManager.pushToPhtoBrower(with: index)
    }
    
    
    func saveAction(_ feedback: String) -> Observable<Bool>{
        
        let subject = PublishSubject<Bool>()
        provider.request(.feedback(text: feedback))
            .toRawDataDictionary()
            .subscribe(onNext: {_ in
                subject.onNext(true)
                self.coordinator.pop()
            }, onError: { _ in
                subject.onNext(false)
            })
            .disposed(by: self.bag)
        
        return subject.asObservable()
        
    }
    

}


extension MeFeedbackViewModel {
    
    fileprivate func loadAssets(with compeleteHandle:@escaping (Bool)->()) {
        
        if allPhotos.count != 0 {
            compeleteHandle(true)
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus();
        if (status == .notDetermined) {
            PHPhotoLibrary.requestAuthorization{ status in
                if (status == .authorized) {
                    DispatchQueue.global().async {
                        self.performLoadAssets()
                        compeleteHandle(true)
                    }
                }else{
                    compeleteHandle(false)
                }
            }
        } else if (status == .authorized) {
            DispatchQueue.global().async {
                self.performLoadAssets()
                compeleteHandle(true)
            }
        }else {
            compeleteHandle(false)
        }
    }
    
    fileprivate func performLoadAssets() {
    
        let options = PHFetchOptions();
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)];
        let fetchResults = PHAsset.fetchAssets(with: .image, options: options)
        fetchResults.enumerateObjects { asset, index, stop in
            self.allPhotos.append(asset)
        }
    }
}
