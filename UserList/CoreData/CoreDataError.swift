//
//  CoreDataError.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation

public enum CoreDataError: Error {
    case entityNotFound(String)
    case saveError(String)
    case readError(String)
    case deleteError(String)
    
    public var description: String {
        switch self {
        case .entityNotFound(let object): return "즐겨찾기 객체 \(object) Not found"
        case .saveError(let message): return "즐겨찾기 저장 에러 \(message)"
        case .readError(let message): return "즐겨찾기 불러오기 에러 \(message)"
        case .deleteError(let message): return "즐겨찾기 삭제 에러 \(message)"
        }
    }
}
