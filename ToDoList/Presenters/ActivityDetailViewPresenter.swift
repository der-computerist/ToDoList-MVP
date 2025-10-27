//
//  ActivityDetailViewPresenter.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 10/23/25.
//

import Foundation

class ActivityDetailViewPresenter {
    
    // MARK: - Properties
    private weak var view: ActivityDetailViewProtocol?
    
    private lazy var activityBuilder = ActivityBuilder(activity: activity) {
        didSet {
            view?.refresh()
        }
    }
    
    private var activity: Activity
    private let activityRepository: ActivityRepository
    
    // MARK: - Initialization
    init(
        activity: Activity?,
        activityRepository: ActivityRepository,
        view: ActivityDetailViewProtocol
    ) {
        self.activityRepository = activityRepository
        self.view = view
        
        if let existingActivity = activity {
            self.activity = existingActivity
        } else {
            self.activity = Activity.emptyActivity
        }
    }
    
    // MARK: - Methods
    
    func didUpdateName(_ name: String) {
        activityBuilder.name = name
    }
    
    func didUpdateDescription(_ description: String) {
        activityBuilder.description = description
    }
    
    func didUpdateStatus(enabled: Bool) {
        activityBuilder.status = enabled ? .done : .pending
    }
    
    func shouldPreventDismissal() -> Bool {
        activityBuilder.hasChanges()
    }
    
    func dismiss() {
        view?.dismiss()
    }
}
