//
//  UserAnimeListAPIRequest.swift
//  OtakuSigma
//
//  Created by Timmy Nguyen on 10/26/23.
//

import Foundation

// note: related animes/mangas are not available with this request (requires detail request)
struct UserListAPIRequest<T: Media>: APIRequest {
    var status: any MediaListStatus
    var sort: any MediaSort
    var fields: [String]
    var limit: Int
    var offset: Int
    
    var urlRequest: URLRequest {
        var urlComponents = URLComponents(string: T.userBaseURL)!
        urlComponents.queryItems = [
            "status": status.key,
            "sort": sort.key,
            "fields": fields.joined(separator: ","),
            "limit": "\(limit)",
            "offset": "\(offset)"
        ].map { URLQueryItem(name: $0.key, value: $0.value) }
        var request = URLRequest(url: urlComponents.url!)
        if let accessToken = Settings.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    func decodeResponse(data: Data) throws -> [T] {
        let decoder = JSONDecoder()
        let weebItemResponse = try decoder.decode(MediaListResponse<T>.self, from: data)
        return weebItemResponse.data.map { $0.node }
    }
}
