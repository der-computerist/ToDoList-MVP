//
//  LandingViewPresenter.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 10/16/25.
//

import Foundation

class LandingViewPresenter {
    
    // MARK: - Properties
    private weak var view: LandingViewProtocol?
    private let activityRepository: NSObject & ActivityRepository
    private var observation: NSKeyValueObservation!
    
    // MARK: - Initialization
    init(activityRepository: NSObject & ActivityRepository, view: LandingViewProtocol) {
        self.activityRepository = activityRepository
        self.view = view
        
        self.observation = observeActivitiesCount(on: activityRepository)
    }
    
    // MARK: - Methods
    func didTapAddButton() {
        view?.didTapAddButton()
    }
    
    private func observeActivitiesCount<T: NSObject & ActivityRepository>(
        on subject: T
    ) -> NSKeyValueObservation {
        
        subject.observe(\.activitiesCount, options: [.initial, .new]) { [weak self] subject, _ in
            DispatchQueue.main.async {
                self?.updateActivitiesCountLabel(with: subject.activitiesCount)
            }
        }
    }
    
    private func updateActivitiesCountLabel(with newActivitiesCount: Int) {
        view?.activitiesCountLabel = "Total: \(newActivitiesCount)"
    }
}
