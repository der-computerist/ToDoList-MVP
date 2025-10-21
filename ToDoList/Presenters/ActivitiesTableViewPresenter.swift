//
//  ActivitiesTableViewPresenter.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 10/20/25.
//

import Foundation

// MARK: - ActivitiesTableViewPresenter
class ActivitiesTableViewPresenter {
    
    // MARK: Properties
    private weak var tableView: ActivitiesTableViewProtocol?
    private let activityRepository: NSObject & ActivityRepository
    private var observation: NSKeyValueObservation!
    
    private var activities: [Activity] { activityRepository.activities }
    
    // MARK: Initialization
    init(
        activityRepository: NSObject & ActivityRepository,
        tableView: ActivitiesTableViewProtocol
    ) {
        self.activityRepository = activityRepository
        self.tableView = tableView
        
        self.observation = observeActivities(on: activityRepository)
    }
    
    // MARK: Methods
    func numberOfRows() -> Int {
        activities.count
    }
    
    func cellData(for indexPath: IndexPath) -> ActivityCellViewData {
        let activity = activities[indexPath.row]
        let icon: ActivityStatusIcon = activity.status == .done ? .checked : .unchecked
        
        return ActivityCellViewData(name: activity.name, status: icon)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let selectedActivity = activities[indexPath.row]
        tableView?.didSelectActivity(selectedActivity)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        let activity = activities[indexPath.row]
        activityRepository.delete(activity: activity)
    }
    
    func activityIdentifier(at indexPath: IndexPath) -> ActivityID? {
        guard indexPath.row < activityRepository.activitiesCount else { return nil }
        return activities[indexPath.row].id
    }
    
    func indexPathForActivity(withIdentifier identifier: String) -> IndexPath? {
        guard let activity = activityRepository.activity(fromIdentifier: identifier),
           let index = activities.firstIndex(of: activity) else {
            return nil
        }
        return IndexPath(row: index, section: 0)
    }
    
    private func observeActivities<T: NSObject & ActivityRepository>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activities, options: .new) { [weak self] _, change in
            switch change.kind {
            case .removal:
                guard let oldIndex = change.indexes?.first else { return }
                let indexPaths = [IndexPath(row: oldIndex, section: 0)]
                DispatchQueue.main.async {
                    self?.tableView?.deleteRows(at: indexPaths)
                }
            default:
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            }
        }
    }
}

// MARK: Testing
#if TEST
extension ActivitiesTableViewPresenter {
    
    /// Test hook to stop model observation.
    ///
    /// Intented to be used by tests that are only interested in validating that view actions
    /// trigger the expected model changes. This is necessary because, if we don't invalidate
    /// the model observation, some of these tests can become flaky.
    func invalidateObservation() {
        observation?.invalidate()
    }
}
#endif

// MARK: - ActivityCellViewData
struct ActivityCellViewData {
    let name: String
    let status: ActivityStatusIcon
}

enum ActivityStatusIcon {
    case checked
    case unchecked
}
