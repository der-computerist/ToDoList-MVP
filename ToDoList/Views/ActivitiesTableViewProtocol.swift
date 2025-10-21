//
//  ActivitiesTableViewProtocol.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 10/20/25.
//

import Foundation

protocol ActivitiesTableViewProtocol: AnyObject {
    
    func reloadData()
    func deleteRows(at indexPaths: [IndexPath])
    func didSelectActivity(_ activity: Activity)
}
