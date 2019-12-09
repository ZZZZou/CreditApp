//
//  ImgTextButton.swift
//  DingDingBusInternational
//
//  Created by hujunn on 2017/11/1.
//  Copyright © 2017年 huatu. All rights reserved.
//  postulate

import UIKit

typealias ImgTextButtonClick = (_ touch: Int) -> Void
class ImgTextButton: UIView {

    private let imgView: UIImageView = UIImageView()
    private let textLabel: UILabel = UILabel()
    
    private var topImg: UIImage?
    private var BottomText: String
    private var viewTag: Int = 0
    var buttonClick: ImgTextButtonClick?
    
    init(img: UIImage?, text: String, tag: Int) {
        topImg = img
        BottomText = text
        viewTag = tag
        super.init(frame: CGRect.zero)

        imgView.image = img
        textLabel.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        makeUI()
    }
    private func makeUI() {
        addSubview(imgView)
        addSubview(textLabel)
        imgView.contentMode = .center
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 10)
        textLabel.textColor = UIColor(hex: "666666")
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(-2)
            make.right.equalTo(2)
            make.bottom.equalTo(0)
            make.height.equalTo(22)
        }
        imgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(9)
            make.bottom.equalTo(textLabel.snp.top)
        }
    }
    
    func setTopImage(_ img: UIImage?) {
        imgView.image = img
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let c = buttonClick {
            c(viewTag)
        }
    }
}

