//
//  Extension + bundle.swift
//  UserList
//
//  Created by paytalab on 5/30/24.
//

import Foundation

extension Bundle {
    
    var apiKey: String? {
        guard let file = self.path(forResource: "Secrets", ofType: "plist"),
              let resource = NSDictionary(contentsOfFile: file),
              let key = resource["API_KEY"] as? String else {
            debugPrint("API KEY를 가져오는데 실패하였습니다.")
            return nil
        }
        return key
    }
    
}
