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
    private let activityRepository: ActivityRepository
    
    // MARK: - Initialization
    init(activityRepository: ActivityRepository, view: ActivityDetailViewProtocol) {
        self.activityRepository = activityRepository
        self.view = view
    }
    
    // MARK: - Methods
}
