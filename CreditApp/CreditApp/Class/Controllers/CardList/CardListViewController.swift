//
//  CardListViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/20.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Charts
import UIKit
import RxCocoa
import RxSwift

class CardListViewController: UIViewController, BindableType {
    
    var refresh: UIRefreshControl = UIRefreshControl()
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dateForAccount: UILabel!
    @IBOutlet weak var dateForRepay: UILabel!
    @IBOutlet weak var amountOfInterst: UILabel!
    @IBOutlet weak var totalAmountOfInterst: UILabel!
    @IBOutlet weak var amountsForRepay: UILabel!
    @IBOutlet weak var restartBtn: UIButton!
    
    
    @IBOutlet weak var cicleView: PieChartView!
    @IBOutlet weak var detailBtn: UIButton!
    
    
    @IBOutlet weak var addBtnInBackgroundView: UIButton!
    @IBOutlet weak var placeholderLabel1: UILabel!
    @IBOutlet weak var placeholderLabel2: UILabel!
    
    var viewModel: CardListViewModel!
    let bag = DisposeBag()
    
    var scrollViewShouldDecelerate: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func bindViewModel() {
        
        viewModel.cards
            .map{cardList -> Bool in
                if let first = cardList.first, first.isDemo {
                    return false
                }
                return true
            }
            .bind{[unowned self] bl in
                self.placeholderLabel1.isHidden = bl
                self.placeholderLabel2.isHidden = bl
                self.addBtnInBackgroundView.isHidden = bl
            }
            .disposed(by: self.bag)
        
        refresh.rx.action = viewModel.refreshAction()
        
        NotificationCenter.default.rx
            .notification(NSNotification.Name("didAddMail"))
            .bind{[unowned self] _ in
                self.refreshSendActions()
            }.disposed(by: bag)
        
        addBtn.rx.action = viewModel.addAction
        addBtnInBackgroundView.rx.action = viewModel.addAction
        
        viewModel.cards
            .bind(to: collection.rx.items){ collection, row, item in
                if item.isEmpty {
                    let cell = collection.dequeueReusableCell(withReuseIdentifier: "add", for: IndexPath(item: row, section: 0))
                    return cell
                }else{
                    let cell = collection.dequeueReusableCell(withReuseIdentifier: "card", for: IndexPath(item: row, section: 0)) as! CardListCollectionViewCell
                    cell.cellWithModel(item)
                    return cell
                }
        }.disposed(by: bag)
        
        viewModel.itemIndexSwitched
            .filter(viewModel.indexIsValid)
            .bind{ [unowned self] index in
                self.collection.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
            .disposed(by: bag)
        
        detailBtn.rx.tap
            .withLatestFrom(viewModel.itemIndexSwitched){$1}
            .bind(to: viewModel.detailAction.inputs)
            .disposed(by: bag)
        
        restartBtn.rx.tap
            .withLatestFrom(viewModel.itemIndexSwitched){$1}
            .bind(to: viewModel.restartAction.inputs)
            .disposed(by: bag)
        
        viewModel.currentLatestMonthData
            .bind{ optionalMonthData in
                
                self.contentView.isHidden = optionalMonthData == nil
                if let monthData = optionalMonthData {
                    self.configContentView(with: monthData)
                }
            }.disposed(by: bag)

        
    }
    
    func setupUI() {
        collection.decelerationRate = UIScrollView.DecelerationRate.fast

        collection.delegate = self
        
        let l = cicleView.legend
        l.enabled = false
        
        refresh.tintColor = UIColor.gray
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refresh
        } else {
            scrollView.addSubview(refresh)
        }

    }
    
    func configContentView(with monthData: ConsumeBillModel) {
        
        let card = viewModel.currentCard
        
        dateForAccount.text = "\(monthData.refund_year)年\(monthData.refund_month)月"
        dateForRepay.text = "\(monthData.payment_due_date_month)月\(card.paymentDueDay)日"
        amountOfInterst.text = String(monthData.total_free)
        totalAmountOfInterst.text = String(card.totalCaptiveFree)
        amountsForRepay.text = String(monthData.banance_RMB)
        
        setupPieChartView(values: [Double(card.totalCaptiveFree), Double(monthData.banance_RMB) ?? 0.0])
        
        restartBtn.isHidden = card.address.count == 0
        
        
    }
    
    func setupPieChartView(values: [Double]) {
        let isAllZero = !values.contains{$0 != 0}
        var entries = values.map{ value in
            PieChartDataEntry(value: value, label: nil)
        }
        var colors = [UIColor.mainOrange, UIColor(hex: "0x7A84D1")]
        if isAllZero {
            entries = [PieChartDataEntry(value: 1, label: nil)]
            colors = [UIColor.gray]
        }
        
        let set = PieChartDataSet(values: entries, label: "Interest And Repay")
        set.drawIconsEnabled = false
        set.sliceSpace = 0
        set.colors = colors
        set.drawValuesEnabled = false
        set.selectionShift = 0
        
        let data = PieChartData(dataSet: set)
        
        
        cicleView.noDataText = ""
        cicleView.holeRadiusPercent = 0.8
        cicleView.data = data
    }
    
    fileprivate func refreshSendActions() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -self.refresh.height - 5), animated: true)
        SwiftTools.timeDelayWithTmer(0.5) {[unowned self] in
            self.refresh.beginRefreshing()
            self.refresh.sendActions(for: .valueChanged)
        }
    }
    
    deinit {
        print("card list view controller didinit")
    }
    
}

extension CardListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isCurrentItem = viewModel.itemIndexSwitched.value == indexPath.item
        
        if isCurrentItem{
            if viewModel.card(with: indexPath.item).isEmpty {
                viewModel.addAction.execute(())
            }
        }else{
            viewModel.itemIndexSwitched.accept(indexPath.item)
        }
    }

    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        scrollViewShouldDecelerate = decelerate
        guard decelerate == false else {
            return
        }
        
        var index = viewModel.itemIndexSwitched.value
        var minDistance = CGFloat.greatestFiniteMagnitude
        let center = collection.contentOffset.x + collection.bounds.width/2
        for cell in collection.visibleCells {
            let distance = abs(cell.center.x - center)
            if distance < minDistance {
                minDistance = distance
                index = collection.indexPath(for: cell)!.item
            }
        }
        viewModel.itemIndexSwitched.accept(index)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        guard scrollViewShouldDecelerate else {
            return
        }
        var index = viewModel.itemIndexSwitched.value
        var minDistance = CGFloat.greatestFiniteMagnitude
        let center = collection.contentOffset.x + collection.bounds.width/2
        for cell in collection.visibleCells {
            let distance = abs(cell.center.x - center)
            if distance < minDistance {
                minDistance = distance
                index = collection.indexPath(for: cell)!.item
            }
        }
        viewModel.itemIndexSwitched.accept(index)
    }
}
