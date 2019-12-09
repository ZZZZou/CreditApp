//
//  MyTableViewAnimatedSectionDataSource.swift
//  CreditApp
//
//  Created by wang on 2018/12/2.
//  Copyright © 2018 CreditManager. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import Foundation
import UIKit
import Differentiator

open class CellSizeTableViewSectionedAnimatedDataSourcer<S: AnimatableSectionModelType>
    : TableViewSectionedDataSource<S>
, RxTableViewDataSourceType {
    public typealias Element = [S]
    public typealias DecideViewTransition = (TableViewSectionedDataSource<S>, UITableView, [Changeset<S>]) -> ViewTransition

    public var animationConfiguration: AnimationConfiguration
    
    /// Calculates view transition depending on type of changes
    public var decideViewTransition: DecideViewTransition
    
    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideViewTransition = decideViewTransition
        super.init(
            configureCell: configureCell,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath,
            sectionIndexTitles: sectionIndexTitles,
            sectionForSectionIndexTitle: sectionForSectionIndexTitle
        )
    }

    var dataSet = false
    
    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
           
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                tableView.reloadData()
            }
            else {
                DispatchQueue.main.async {
                    // if view is not in view hierarchy, performing batch updates will crash the app
                    if tableView.window == nil {
                        dataSource.setSections(newSections)
                        tableView.reloadData()
                        return
                    }
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                        
                        switch self.decideViewTransition(self, tableView, differences) {
                        case .animated:
                            for difference in differences {
                                dataSource.setSections(difference.finalSections)
                                let offset = tableView.contentOffset
                                
                                if difference.deletedItems.count > 0 || difference.deletedSections.count > 0 {
                                    
                                    UIView.setAnimationsEnabled(false)
                                    tableView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                                    UIView.setAnimationsEnabled(true)
                                    
                                }else{
                                    tableView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                                    
                                }
                                
                                //模拟手动滑动tableview
                                tableView.contentOffset.y += tableView.contentOffset.y+10
//                                tableView.setNeedsLayout()
                                tableView.layoutIfNeeded()
                                if tableView.contentSize.height > tableView.frame.height && offset.y >= tableView.contentSize.height - tableView.frame.height {
                                    tableView.contentOffset.y = tableView.contentSize.height - tableView.frame.height
                                }else{
                                    tableView.contentOffset = offset
                                }
                                
                            }
                        case .reload:
                            self.setSections(newSections)
                            tableView.reloadData()
                            return
                        }
                    }
                    catch let e {
                        
                        self.setSections(newSections)
                        tableView.reloadData()
                    }
                }
            }
            }.on(observedEvent)
    }
}

