//
//  LoginViewController.swift
//  CreditApp
//
//  Created by 林勇彬 on 2018/8/30.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import MBProgressHUD
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class LoginViewController: UIViewController, BindableType, Prealm {
    
    var viewModel: LoginViewModel!
    var bag = DisposeBag()
    var timeout = PublishRelay<Int>()
    var timerDispose: Disposable!

    lazy var nowDate: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date(timeIntervalSinceNow: 0)
        return dateFormatter.string(from: date)
    }()

    @IBOutlet weak var iphoneTextField: UITextField!
    @IBOutlet weak var captchaTextField: UITextField!
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var getCaptchaBtn: UIButton!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var dissBtn: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var agreementBtn: UIButton!
    // MARK: - life cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    func bindViewModel() {
        
        let iphoneIsValid = iphoneTextField.rx
            .controlProperty(editingEvents: [.editingChanged, .editingDidEndOnExit], getter: {$0.text}, setter: {filed, text in })
            .map(viewModel.validateIphoneNum)
            .share(replay: 1);
        let captchaIsValid = captchaTextField.rx
            .controlProperty(editingEvents: [.editingChanged, .editingDidEndOnExit], getter: {$0.text}, setter: {filed, text in })
            .map(viewModel.validateCaptcha)
            .share(replay: 1)
        
        
        iphoneIsValid
            .skip(1)
            .bind { [weak self] bl in
                self?.line1.backgroundColor = bl ?UIColor.backgroundGray :UIColor(hex: "0xD0021B")
            }
            .disposed(by: bag)
        
        iphoneIsValid.bind(to: getCaptchaBtn.rx.isEnabled).disposed(by: bag)
        iphoneIsValid
            .filter{$0}
            .withLatestFrom(captchaIsValid){$1}
            .bind{ [unowned self] bl in
                
                if bl {
                    self.iphoneTextField.endEditing(true)
                }else {
                    self.captchaTextField.becomeFirstResponder()
                }
            }
            .disposed(by: bag)
        
        captchaIsValid
            .skip(1)
            .bind { [weak self] bl in
                self?.line2.backgroundColor = bl ?UIColor.backgroundGray :UIColor(hex: "0xD0021B")
            }
            .disposed(by: bag)
        captchaIsValid
            .filter{$0}
            .bind{ [unowned self] _ in
                self.captchaTextField.endEditing(true)
            }
            .disposed(by: bag)
        
        Observable.combineLatest(iphoneIsValid, captchaIsValid){ $0 && $1 }
            .bind{      [weak self] bl in
                if let self = self {
                    self.sureBtn.isEnabled = bl
                    self.sureBtn.backgroundColor = bl ? UIColor.mainOrange : UIColor(hex: "0xdddddd")
                }
        }.disposed(by: bag)
        
        getCaptchaBtn.rx.tap
            .do(onNext: {  [weak self] in
                guard let self = self else {return}
                if self.getCaptchaBtn.isEnabled {
                    self.timerDispose = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
                        .subscribe(onNext:{ second in
                            if second == 60 {
                                self.timeout.accept(second)
                                return
                            }
                            self.getCaptchaBtn.isEnabled = false
                            self.getCaptchaBtn.setTitle(String(60-second)+"s", for: .normal)
                            self.getCaptchaBtn.setTitleColor(UIColor.textGray, for: .normal)
                            
                        })
                }
            }).filter({ [unowned self] (_) -> Bool in
                let result = self.realmAuthTimeModelSearch(self.nowDate)
        
                if let model = result.first {
                    if model.num >= 3 {
                        return false
                    } else {
                        let realm = try! Realm()
                        try! realm.write {
                            model.num += 1
                        }
                        return true
                    }
                } else {
                    let auth = AuthTimeModel()
                    auth.nowDate = self.nowDate
                    _ = self.realmAddModel(auth)
                    return true
                }
                
            }).map({ [unowned self] _ -> (String, String) in
                (self.iphoneTextField.text!, self.iphoneTextField.text!.toLoginNumber())
            })
            .bind(to: viewModel.authCodeAction.inputs)
            .disposed(by: bag)

        
//        getCaptchaBtn.rx.tap
//            .bind{ [weak self] in
//                guard let self = self else {return}
//                if self.getCaptchaBtn.isEnabled {
//                    self.timerDispose = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
//                        .subscribe(onNext:{ second in
//                            if second == 60 {
//                                self.timeout.accept(second)
//                                return
//                            }
//                            self.getCaptchaBtn.isEnabled = false
//                            self.getCaptchaBtn.setTitle(String(60-second)+"s", for: .normal)
//                            self.getCaptchaBtn.setTitleColor(UIColor.textGray, for: .normal)
//
//                        })
//                }
//        }.disposed(by: bag)
        
        timeout.bind{ [unowned self] second in
            self.timerDispose.dispose()
            self.getCaptchaBtn.isEnabled = true
            self.getCaptchaBtn.setTitle("获取验证码", for: .normal)
            self.getCaptchaBtn.setTitleColor(UIColor.mainOrange, for: .normal)
        }.disposed(by: bag)
        
        sureBtn.rx.tap
            .map{ [unowned self] _ -> (String, String) in
                (self.iphoneTextField.text!, self.captchaTextField.text!)
            }
            .bind{[unowned self] iphone, captcha in
                MBProgressHUD.showHUD(addedTo: self.view)
                self.viewModel.loginAction(iphone: iphone, captcha: captcha)
                    .bind{ result in
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
        
        dissBtn.rx.action = viewModel.dissAction()
        agreementBtn.rx.action = viewModel.loadWebAction
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
    deinit {
        print("login view controller deinit")
    }
}
