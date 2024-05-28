//
//  User.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation

public struct UserResult: Decodable {
    public let totalCount: Int
    public let incompleteResults: Bool
    public let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalCount = try container.decode(Int.self, forKey: .totalCount)
        self.incompleteResults = try container.decode(Bool.self, forKey: .incompleteResults)
        self.items = try container.decode([User].self, forKey: .items)
    }
}

public struct User: Decodable {
    public let id: Int
    public let login: String
    public let imageURL: String
    public var favorite: Bool = false
  
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case imageURL = "avatar_url"
    }
    
    public init(id: Int, login: String, imageURL: String) {
        self.id = id
        self.login = login
        self.imageURL = imageURL
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.login = try container.decode(String.self, forKey: .login)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
    }
}
