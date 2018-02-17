//
//  ParseltongueRouter.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 15/11/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get, post
}

enum ParseltongueRouter {

    static let baseUrl = "https://parseltongue.onmap.co.il/v1/"

    case getTranslations(String)
    case postKey(appId: String, key: String, token: String)
    case postKeys(appId: String, keys: [String], token: String)

    func urlRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue.uppercased()

        if method == .post {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue(token ?? "", forHTTPHeaderField: "access_token")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters as Any)
            } catch {
                print(error.localizedDescription)
            }
        }
        return urlRequest
    }

    var method: HTTPMethod {
        switch self {
        case .getTranslations:
            return .get
        case .postKey, .postKeys:
            return .post
        }
    }

    var url: URL {
        let relativePath: String
        switch self {
        case .getTranslations(let appID):
            return URL(string: ParseltongueRouter.baseUrl + "translations?app_id=\(appID)")!
        case .postKey, .postKeys:
            relativePath = "keys"
        }
        var url = URL(string: ParseltongueRouter.baseUrl)!
        url.appendPathComponent(relativePath)
        return url
    }

    var parameters: [String: Any]? {
        switch self {
        case .getTranslations:
            return nil
        case .postKey(let appID, let key, _):
            return ["app_id": appID, "name": key]
        case .postKeys(let appID, let keys, _):
            return ["app_id": appID, "names": keys]
        }
    }

    var token: String? {
        switch self {
        case .getTranslations:
            return nil
        case .postKey(_, _, let token):
            return token
        case .postKeys(_, _, let token):
            return token
        }
    }
}
