//
//  Network.swift
//  UserList
//
//  Created by paytalab on 5/27/24.
//

import Foundation
import Alamofire

final public class NetworkManager {
    private let session: Session
    private let tokenHeaders: HTTPHeaders? = {
        guard let apiKey = Bundle.main.apiKey else { return nil }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(apiKey)"]
        return headers
    }()
    
    init(session: Session = Session.default) {
        self.session = session
    }
    
    func fetchData<T:Decodable> (url: String, method: HTTPMethod, dataType: T.Type) async -> Result<T, Error> {
        guard let url = URL(string: url) else {
            return .failure(NetworkError.urlError)
        }
        print("url - \(url)")
      
        let result = await session.request(url, method: method, headers: tokenHeaders).validate().serializingData().response
        guard let data = result.data else { return .failure(NetworkError.dataNil) }
        guard let response =  result.response else { return .failure(NetworkError.invalid) }
        
        if 200..<400 ~= response.statusCode {
            do {
                let data = try JSONDecoder().decode(T.self, from: data)
                return .success(data)
            } catch {
                return .failure(NetworkError.failToDecode(error.localizedDescription))
            }
        } else {
            debugPrint(result.error?.localizedDescription)
            return .failure(NetworkError.serverError(response.statusCode))
        }
    }
}
