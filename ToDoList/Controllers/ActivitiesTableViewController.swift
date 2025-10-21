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
    private var activities: [Activity] { activityRepository.activities }
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
        activities.count
    }

    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.name

        switch activity.status {
        case .pending:
            cell.imageView?.image = Assets.pendingActivityImage
        case .done:
            cell.imageView?.image = Assets.doneActivityImage
        }
        
        return cell
    }
    
    public override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let activity = activities[indexPath.row]
            activityRepository.delete(activity: activity)
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
    
    public func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String? {
        guard !idx.isEmpty else { return nil }
        return activities[idx.row].id
    }
    
    public func indexPathForElement(
        withModelIdentifier identifier: String,
        in view: UIView
    ) -> IndexPath? {
        
        guard let activity = activityRepository.activity(fromIdentifier: identifier),
              let index = activities.firstIndex(of: activity) else {
            return nil
        }
        return IndexPath(row: index, section: 0)
    }
}

// MARK: - Constants
extension ActivitiesTableViewController {
    
    enum Assets {
        static let doneActivityImage = UIImage(named: "Checked")
        static let pendingActivityImage = UIImage(named: "Unchecked")
    }
    
    enum Constants {
        static let cellReuseIdentifier = "UITableViewCell"
    }
    
    enum Restoration {
        static let viewControllerIdentifier = String(describing: ActivitiesTableViewController.self)
        static let tableViewIdentifier = viewControllerIdentifier + "TableView"
    }
}
