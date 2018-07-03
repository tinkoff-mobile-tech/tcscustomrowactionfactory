//
//  RowActionView.swift
//  TCSTableViewRowActionFactory_Example
//
//  Created by Alexander Trushin on 04.04.2018.
//  Copyright © 2018 Tinkoff.ru. All rights reserved.
//

import UIKit

class RowActionView: UIView {
    
    // MARK: Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    
    
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    
    // MARK: Public
    
    func configure(with type: RowActionType) {
        switch type {
        case .like:
            imageView.image = #imageLiteral(resourceName: "row_action_like_icon")
            titleLabel.text = "Like"
            titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 14)
        case .repost:
            imageView.image = #imageLiteral(resourceName: "row_action_repost_icon")
            titleLabel.text = "Repost"
            imageView.transform = CGAffineTransform(translationX: -5, y: 0)
            titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 14)
        case .save:
            imageView.image = #imageLiteral(resourceName: "row_action_save_icon")
            titleLabel.text = "Save"
            titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 14)
        }
    }
    
    
    // MARK: Private
    
    private func setupView() {
        backgroundColor = .clear
        
        imageView.tintColor = .white
        
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 11)
    }
    
}
