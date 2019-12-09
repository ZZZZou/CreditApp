//
//  MeFeedbackViewController.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/8.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import Action
import RxSwift
import MWPhotoBrowser
import UIKit

class MeFeedbackViewController: UIViewController, BindableType {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countOfWords: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var countOfImage: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    let bag = DisposeBag()
    var viewModel: MeFeedbackViewModel!
    let placeholdString = "请输入您的反馈意见"
    let maxCountOfWords = 1000
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func bindViewModel() {
        
        submitBtn.rx.tap
            .bind{ [unowned self] in

                MBProgressHUD.showHUD()
                let feedback = self.textView.text!
                self.viewModel.saveAction(feedback)
                    .bind{ result in
                        if result {
                            MBProgressHUD.showSuccess("反馈提交成功")
                        }else {
                            MBProgressHUD.showError("反馈提交失败")
                        }
                    }
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
        
        textView.rx.didEndEditing
            .filter(self.textViewIsEmpty)
            .bind{ [unowned self] isEmpty in
                self.textView.text = self.placeholdString
                self.textView.textColor = UIColor.textGray
            }
            .disposed(by: bag)
        
        textView.rx.didBeginEditing
            .filter(self.textViewIsEmpty)
            .bind{ [unowned self] in
                self.textView.text = ""
                self.textView.textColor = UIColor.textBlack
            }
            .disposed(by: bag)
        
        textView.rx.didChange
            .filter(self.textViewIsUnMarked)
            .bind{ [unowned self]  in
                let origin = self.textView.text ?? ""
                if origin.count > self.maxCountOfWords {
                    let start = origin.startIndex
                    let end = origin.index(start, offsetBy: self.maxCountOfWords-1)
                    self.textView.text = String(origin[start...end])
                }
                
                let count = self.textView.text.count
                self.countOfWords.text = "\(count)\\\(self.maxCountOfWords)"
                if count == self.maxCountOfWords {
                    self.countOfWords.textColor = UIColor.red
                }else{
                    self.countOfWords.textColor = UIColor.textGray
                }
                
                self.submitBtn.isEnabled = count > 0
            }
            .disposed(by: bag)
        
        
        viewModel.selectedImageModels
            .bind(to: collection.rx.items){collection, row, item in
                let cell = collection.dequeueReusableCell(withReuseIdentifier: "item", for: IndexPath(item: row, section: 0)) as! MeFeedbackCollectionViewCell
                cell.config(with: item)
                return cell
            }
            .disposed(by: bag)
    }
    
    func textViewIsEmpty() -> Bool {
        return self.textView.text.count == 0 || self.textView.text == self.placeholdString
    }
    
    func textViewIsUnMarked() -> Bool {
        let selectedRange = textView.markedTextRange;
        return selectedRange == nil ? true : false
    }
    
    func setupUI() {
        
        submitBtn.isEnabled = false
        
        textView.text = placeholdString
        textView.textColor = UIColor.textGray
        textView.delegate = self
        
        collection.delegate = self
    }
    
    deinit{
        print("feedback viewcontroller is deinit")
    }
}

extension MeFeedbackViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

var action: CocoaAction!

extension MeFeedbackViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let hud = MBProgressHUD.showHUD(addedTo: self.view)
        action = viewModel.didSelectItem(at: indexPath.item)
        action.execute(())
        action.enabled
            .bind{ bl in
                if bl {hud.hide(animated: true)}
            }
            .disposed(by: bag)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 60, height: 60)
    }
}




