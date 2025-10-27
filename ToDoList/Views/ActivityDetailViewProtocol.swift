//
//  ActivityDetailViewProtocol.swift
//  ToDoList
//
//  Created by Enrique Aliaga on 10/23/25.
//

import Foundation

protocol ActivityDetailViewProtocol: AnyObject {
    
    func presentSaveConfirmation()
    func presentErrorAlert(error: Error)
    func refresh()
    func dismiss()
}
