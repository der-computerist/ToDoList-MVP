//
//  ActivitiesTableViewController.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 11/5/21.
//

import UIKit

public protocol ActivitiesTableViewControllerDelegate: AnyObject {
    
    func activitiesTableViewController(
        _ viewController: ActivitiesTableViewController,
        didSelectActivity activity: Activity
    )
}

public final class ActivitiesTableViewController: NiblessTableViewController {
    
    // MARK: - Properties
    internal var presenter: ActivitiesTableViewPresenter?
    public weak var delegate: ActivitiesTableViewControllerDelegate?
    
    private let activityRepository: NSObject & ActivityRepository
    private let cellIdentifier = Constants.cellReuseIdentifier
    
    // MARK: - Methods
    public init(activityRepository: NSObject & ActivityRepository) {
        self.activityRepository = activityRepository
        super.init(style: .plain)
        restorationIdentifier = Restoration.viewControllerIdentifier
    }
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self  // For some reason, this is needed for
                                     // `UIDataSourceModelAssociation` methods to be called.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.restorationIdentifier = Restoration.tableViewIdentifier
        
        presenter = ActivitiesTableViewPresenter(
            activityRepository: activityRepository,
            tableView: self
        )
    }
}

// MARK: - UITableViewDataSource
extension ActivitiesTableViewController {
    
    public override func tableView(_ _: UITableView, numberOfRowsInSection _: Int) -> Int {
        presenter?.numberOfRows() ?? 0
    }

    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let cellData = presenter?.cellData(for: indexPath) else {
            return cell
        }
        
        cell.textLabel?.text = cellData.name
        cell.imageView?.image = UIImage.icon(for: cellData.status)
        
        return cell
    }
    
    public override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            presenter?.deleteRow(at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension ActivitiesTableViewController {
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectRow(at: indexPath)
    }
}

// MARK: - ActivitiesTableViewProtocol
extension ActivitiesTableViewController: ActivitiesTableViewProtocol {
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func deleteRows(at indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func didSelectActivity(_ activity: Activity) {
        delegate?.activitiesTableViewController(self, didSelectActivity: activity)
    }
}

// MARK: - State Restoration
extension ActivitiesTableViewController: UIDataSourceModelAssociation {
    
    public func modelIdentifierForElement(at indexPath: IndexPath, in view: UIView) -> String? {
        guard !indexPath.isEmpty else { return nil }
        return presenter?.activityIdentifier(at: indexPath)
    }
    
    public func indexPathForElement(
        withModelIdentifier identifier: String,
        in view: UIView
    ) -> IndexPath? {
        
        presenter?.indexPathForActivity(withIdentifier: identifier)
    }
}

// MARK: UIImage extension
private extension UIImage {
    
    static func icon(for activityStatus: ActivityStatusIcon) -> UIImage? {
        switch activityStatus {
        case .checked:
            UIImage(named: ImageName.checkedActivityImageName)
        case .unchecked:
            UIImage(named: ImageName.uncheckedActivityImageName)
        }
    }
    
    private enum ImageName {
        static let checkedActivityImageName = "Checked"
        static let uncheckedActivityImageName = "Unchecked"
    }
}

// MARK: - Constants
extension ActivitiesTableViewController {
    
    enum Constants {
        static let cellReuseIdentifier = "UITableViewCell"
    }
    
    enum Restoration {
        static let viewControllerIdentifier = String(describing: ActivitiesTableViewController.self)
        static let tableViewIdentifier = viewControllerIdentifier + "TableView"
    }
}
