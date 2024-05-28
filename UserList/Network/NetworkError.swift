//
//  NetworkError.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation

public enum NetworkError: Error {
    case urlError
    case invalid
    case failToDecode(String)
    case dataNil
    case serverError(Int)
}
