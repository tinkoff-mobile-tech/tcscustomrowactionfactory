//
//  ViewController.swift
//  TCSCustomRowActionFactory
//
//  Created by Alexander Trushin on 05/07/2018.
//  Copyright © 2018 Tinkoff.ru. All rights reserved.
//

import UIKit
import TCSCustomRowActionFactory

class ViewController: UIViewController {

    // MARK: Private Data Structures
    
    private enum Constants {
        static let rowActionWidth: CGFloat = 74
    }
    
    
    // MARK: Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    
    // MARK: Private Properties
    
    private let rowActionTypes: [RowActionType] = [.save, .repost, .like]
    
    
    
    // MARK: Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    
    // MARK: Private
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func createRowActionView(with height: CGFloat, type: RowActionType) -> RowActionView {
        let className = String(describing: RowActionView.self)
        let rowActionView = Bundle.main.loadNibNamed(className, owner: nil, options: nil)?.first as! RowActionView
        rowActionView.frame = CGRect(x: 0, y: 0, width: Constants.rowActionWidth, height: height)
        
        rowActionView.configure(with: type)
        
        rowActionView.layoutIfNeeded()
        
        return rowActionView
    }
    
    private func rowActionBackgroundColor(for type: RowActionType) -> UIColor {
        switch type {
        case .like:
            return .lightGray
        case .repost:
            return .red
        case .save:
            return .green
        }
    }

}




// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Cell \(indexPath.row + 1)"
        
        return cell
    }
}




// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        var rowActions: [UITableViewRowAction] = []
        
        for type in rowActionTypes {
            let rowActionFactory = TCSCustomRowActionFactory { indexPath in
                tableView.setEditing(false, animated: true)
            }
            
            let rowActionView = createRowActionView(with: cell.frame.height, type: type)
            rowActionView.backgroundColor = rowActionBackgroundColor(for: type)
            rowActionFactory.setupForCell(with: rowActionView)
            
            if let rowAction = rowActionFactory.rowAction() {
                rowActions.append(rowAction)
            }
        }
        
        return rowActions
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        var contextualActions: [UIContextualAction] = []
        
        for type in rowActionTypes {
            let rowActionFactory = TCSCustomRowActionFactory { indexPath in
                tableView.setEditing(false, animated: true)
            }
            
            let rowActionView = createRowActionView(with: cell.frame.height, type: type)
            rowActionFactory.setupForCell(with: rowActionView)
            
            if let contextualAction = rowActionFactory.contextualAction(for: indexPath) {
                contextualAction.backgroundColor = rowActionBackgroundColor(for: type)
                contextualActions.append(contextualAction)
            }
        }
        
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: contextualActions)
        swipeActionsConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeActionsConfiguration
    }
}

