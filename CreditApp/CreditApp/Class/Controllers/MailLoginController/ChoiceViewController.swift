//
//  ChoiceViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/4.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

class ChoiceViewController: UIViewController {
    
    fileprivate var modelArray:[ChoiceModel] = {
        var a = [ChoiceModel]()
        let c1 = ChoiceModel(picString: "", address: "163", addName: "163")
        let c2 = ChoiceModel(picString: "", address: "qq", addName: "qq")
        let c4 = ChoiceModel(picString: "", address: "126", addName: "126")

        a.append(c1)
        a.append(c2)
        a.append(c4)

        return a
    }()

     fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "ChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: ChoiceTableViewCell.Identifier)

        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }

    private func makeUI() {
        ddSetTitle("选择邮箱")
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                // Fallback on earlier versions
                make.top.equalTo(view.layoutMarginsGuide).offset(44)
                make.bottom.equalTo(view.layoutMarginsGuide)
            }
            make.left.right.equalTo(0)
        }
    }
}

extension ChoiceViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChoiceTableViewCell.Identifier, for: indexPath) as! ChoiceTableViewCell
        cell.textLabel?.text = modelArray[indexPath.row].addName
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loginVC = WebLoginViewController()
        loginVC.hidesBottomBarWhenPushed = true
        loginVC.viewWithWebLoginAddress(address: modelArray[indexPath.row].address)
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
