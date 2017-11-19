//
//  ParseltongueRouter.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 15/11/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]

enum ParseltongueRouter {

    private static let baseUrl = "https://parseltongue.onmap.co.il/v1/"

    enum HTTPMethod: String {
        case get, post
    }

    case getTranslations(String)
    case postKey(appId: String, key: String, token: String)
    case postKeys(appId: String, keys: [String], token: String)

    var method: HTTPMethod {
        switch self {
        case .getTranslations:
            return .get
        case .postKey, .postKeys:
            return .post
        }
    }

    func asURLRequest() -> URLRequest {

        let url: URL = {
            let relativePath: String
            switch self {
            case .getTranslations(let appId):
                return URL(string: ParseltongueRouter.baseUrl + "translations?app_id=\(appId)")!
            case .postKey, .postKeys:
                relativePath = "keys"
            }
            var url = URL(string: ParseltongueRouter.baseUrl)!
            url.appendPathComponent(relativePath)
            return url
        }()

        let parameters: Parameters? = {
            switch self {
            case .getTranslations:
                return nil
            case .postKey(let appId, let key, _):
                return ["app_id": appId, "name": key]
            case .postKeys(let appId, let keys, _):
                return ["app_id": appId, "names": keys]
            }
        }()

        let token: String? = {
            switch self {
            case .getTranslations:
                return nil
            case .postKey(_, _, let token):
                return token
            case .postKeys(_, _, let token):
                return token
            }
        }()

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
}
