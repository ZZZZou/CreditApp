//
//  CardAutoViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/10/24.
//  Copyright © 2018 hujuun. All rights reserved.
//


import SnapKit
import UIKit
import RxSwift
import XCGLogger

class CardAutoViewController: UIViewController, HhDownload {
    var disposeBag = DisposeBag()
    var logg = XCGLogger.default

    var modelArray: [CMTotalCardModel] = []
    
    lazy fileprivate var collectionView: UICollectionView = {
        let flowLayout = HorizontalFlowLayout()
        flowLayout.itemSize = CGSize(width: 270, height: 180)
        let e = (kWidth - 270) / 2
        flowLayout.minimumLineSpacing = e / 2
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: e, bottom: 0, right: e)
        
        let collect = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collect.autoresizingMask = .flexibleWidth
        collect.decelerationRate = .normal
        collect.delegate = self
        collect.dataSource = self
        collect.alwaysBounceVertical = false
        collect.showsHorizontalScrollIndicator = false
        collect.backgroundColor = UIColor.clear
        collect.register(UINib(nibName: CardAutoCell.Identifier, bundle: nil), forCellWithReuseIdentifier: CardAutoCell.Identifier)
        return collect
    }()
    
    lazy var topBackView: UIView = {
        let t = GraphBackView()
        return t
    }()
    lazy var topLabel: UILabel = {
        let t = UILabel()
        t.text = "信用卡智能体检"
        t.textColor = .white
        t.textAlignment = .center
        t.font = UIFont.systemFont(ofSize: 20)
        return t
    }()
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    private var isFirstLoad = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            makeUI()
            downloadData(isRefreshed: true)
            isFirstLoad = false
        }
    }
    
    // MARK: - public methods
    // MARK: - notification、closume、event response
    // MARK: - private methods
    func makeUI() {
        view.addSubview(topBackView)
        topBackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(view.layoutMarginsGuide)
            }
        }
        topBackView.setNeedsDisplay()
        
       
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(68)
            } else {
                make.top.equalTo(view.layoutMarginsGuide).offset(68)
            }
            make.height.equalTo(180)
        }
        
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(view.layoutMarginsGuide)
            }
            make.bottom.equalTo(collectionView.snp.top)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(200)
        }
        
        // Middle
        let billLabel = UILabel()
        billLabel.text = "本期账单"
        billLabel.textColor = UIColor(hex: "#333333")
        billLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(billLabel)
        billLabel.snp.makeConstraints { (make) in
            make.left.equalTo(34)
            make.top.equalTo(collectionView.snp.bottom).offset(34)
            make.size.equalTo(CGSize(width: 120, height: 28))
        }
        let billLeftView = UIView()
        billLeftView.backgroundColor = UIColor(hex: "#393C45")
        view.addSubview(billLeftView)
        billLeftView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 4, height: 20))
            make.top.equalTo(billLabel.snp.top)
            make.left.equalTo(15)
        }
        
        
    }
    
    fileprivate func downloadData(isRefreshed: Bool = true) {
        let user = UserSingle.sharedInstance
        if !user.isLogined {
            print("not login")
            return
        }
        let parameters = ["userUUID": user.userModel.user_uuid, "isAllUpdate": isRefreshed] as [String : Any]
        _ = downloadToArrayWithParameters(parameters, url: kGetAllCardURL, modeltype: CMTotalCardModel.self).catchError({ (error) -> Observable<[CMTotalCardModel]> in
            if let e = error as? TestInfoError {
                print(e.info)
            }
            return Observable.never()
        }).map({ [unowned self] (models)  in
            self.modelArray = models
            print(models)
            self.collectionView.reloadData()
        }).subscribe().disposed(by: disposeBag)
    }
    

}


extension CardAutoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardAutoCell.Identifier, for: indexPath) as! CardAutoCell
        cell.cellWithModel(model: modelArray[indexPath.row])
        return cell
    }
    
}
