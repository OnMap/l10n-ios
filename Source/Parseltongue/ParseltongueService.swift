//
//  ParseltongueService.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 07/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import Foundation
import SocketIO

enum ParseltongueServiceError: Error {
    case data(reason: String)
    case parsing(reason: String)
    case api(reason: String)
    case dataBase(reason: String)
}

extension ParseltongueServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .data(let reason),
             .parsing(let reason),
             .api(let reason),
             .dataBase(let reason):
            return reason
        }
    }
}

public class ParseltongueService {
    let appID: String
    var socket: SocketIOClient?

    public init(appID: String) {
        self.appID = appID
    }
}

extension ParseltongueService: LocalizationProvider {

    public func localizationsJSON(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let urlRequest = ParseltongueRouter.getTranslations(appID).urlRequest()
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, ParseltongueServiceError.data(reason: "There is no data in response"))
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = jsonObject as? JSONDictionary else {
                    let reason = "Returned object is not a json dictionary:\n\(jsonObject)"
                    completion(nil, ParseltongueServiceError.parsing(reason: reason))
                    return
                }
                if let status = jsonDictionary["status"] as? Int,
                    let name = jsonDictionary["name"] as? String,
                    let message = jsonDictionary["message"] as? String {
                    let reason = "Error \(status): \(name). \(message)"
                    completion(nil, ParseltongueServiceError.api(reason: reason))
                    return
                }
                guard !jsonDictionary.isEmpty else {
                    let reason = "There are no languages in response"
                    completion(nil, ParseltongueServiceError.parsing(reason: reason))
                    return
                }
                completion(jsonDictionary, nil)
            } catch {
                let reason = error.localizedDescription
                completion(nil, ParseltongueServiceError.dataBase(reason: reason))
            }
        }
        task.resume()
    }
}

extension ParseltongueService: LiveUpdatesProvider {

    public func startObservingChanges(parsingBlock: @escaping ([String : Any]) -> Void) {
        let url = ParseltongueRouter.getTranslations(appID).url

        let socket = SocketIOClient(socketURL: url, config: [.log(false), .compress])
        self.socket = socket

        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }

        socket.on(appID) { data, ack in
            guard let json = data[0] as? JSONDictionary else { return }
            parsingBlock(json)
            socket.emitWithAck("canUpdate", 0).timingOut(after: 0) { _ in
                socket.emit("updated")
            }
        }

        socket.connect()
    }

    public func stopObservingChanges() {
        socket?.disconnect()
    }
}
