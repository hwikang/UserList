//
//  CoreDataError.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation

enum CoreDataError: Error {
    case entityNotFound
    case saveError(String)
    case readError(String)
    case deleteError(String)
}
