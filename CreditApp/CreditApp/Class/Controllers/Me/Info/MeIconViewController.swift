//
//  MePictureViewController.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/11.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import MBProgressHUD
import RxSwift
import RxCocoa
import Action
import UIKit

class MeIconViewController: UIViewController, BindableType {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    let bag = DisposeBag()
    var viewModel: MeIconViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bindViewModel() {
        viewModel.user.userinfoChanged
            .bind{[unowned self] user in
                self.icon.image = user.icon
            }
            .disposed(by: bag)
        
        
        
        moreBtn.rx.tap
            .bind{
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancel = UIAlertAction(title: "取消", style: .cancel) { action in
                }
                let takePic = UIAlertAction(title: "拍照", style: .default) { action in
                    self.pickerImage(0)
                }
                let album = UIAlertAction(title: "从手机相册选择", style: .default) { action in
                    self.pickerImage(1)
                }
                let save = UIAlertAction(title: "保存", style: .default) { action in
                    self.pickerImage(2)
                }
                alert.addAction(cancel)
                alert.addAction(takePic)
                alert.addAction(album)
                alert.addAction(save)
                self.present(alert, animated: true, completion: nil)
            }
            .disposed(by: bag)
        
        backBtn.rx.action = viewModel.backAction()
            
    }
    
    func pickerImage(_ index: Int){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if (index == 0) {//拍照
            if ((UIImagePickerController.availableMediaTypes(for: .camera)) == nil){return}
            picker.sourceType = .camera;
            self.modalPresentationStyle = .overCurrentContext
            self.present(picker, animated: true, completion: nil)
        
        
        }else if(index == 1){//相册
            if ((UIImagePickerController.availableMediaTypes(for: .photoLibrary)) == nil) {return}
            picker.sourceType = .photoLibrary
            self.modalPresentationStyle = .overCurrentContext
            self.present(picker, animated: true, completion: nil)
        }else if(index == 2){//保存
            if ((UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)) == nil) {return}
            UIImageWriteToSavedPhotosAlbum(viewModel.user.icon, self, #selector(MeIconViewController.savedPhotoCompleted(with:error:context:)), nil)
        }
    
    }
//    - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
    @objc func savedPhotoCompleted(with image: UIImage, error: Error?, context: UnsafeMutableRawPointer?){
        if error == nil {
            MBProgressHUD.showSuccess("图片已保存到相册")
        }else{
            MBProgressHUD.showError("图片保存失败")
        }
    }

}

extension MeIconViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let value = info[.editedImage];
        if let image = value as? UIImage {
            MBProgressHUD.showHUD("正在上传图片...", addedTo: self.view)
            viewModel.uploadImageAction(image)
                .bind{[unowned self]result in
                    if result {
                        MBProgressHUD.showSuccess("图片上传成功", addedTo: self.view)
                    }else {
                        MBProgressHUD.showError("图片上传失败", addedTo: self.view)
                    }
                }
                .disposed(by: bag)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
