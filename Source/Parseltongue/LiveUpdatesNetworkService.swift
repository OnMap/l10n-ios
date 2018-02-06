//
//  LiveUpdatesNetworkService.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 17/08/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift
import SocketIO

typealias JSONDictionary = [String: Any]

enum LiveUpdatesNetworkServiceError: Error {
    case data(reason: String)
    case parsing(reason: String)
    case api(reason: String)
    case dataBase(reason: String)
}

extension LiveUpdatesNetworkServiceError: LocalizedError {
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

public class LiveUpdatesNetworkService {

    private static var appId: String!

    // MARK: - Public

    public static func setup(appId: String, clearRun: Bool = true) {
        LiveUpdatesNetworkService.appId = appId
        if clearRun {
            deleteExistingRealms()
        }
        fetchAndParseAllLocalizedTexts { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        configureLiveUpdating()
    }

    // MARK: - Private

    private static func deleteExistingRealms() {
        Localization.availableLanguages.forEach { Realm.delete(language: $0) }
    }

    private static func fetchAndParseAllLocalizedTexts(completion: @escaping (Error?) -> Void) {
        let urlRequest = ParseltongueRouter.getTranslations(appId).asURLRequest()
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            guard let data = data else {
                completion(LiveUpdatesNetworkServiceError.data(reason: "There is no data in response"))
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = jsonObject as? JSONDictionary else {
                    let reason = "Returned object is not a json dictionary:\n\(jsonObject)"
                    completion(LiveUpdatesNetworkServiceError.parsing(reason: reason))
                    return
                }
                if let status = jsonDictionary["status"] as? Int,
                    let name = jsonDictionary["name"] as? String,
                    let message = jsonDictionary["message"] as? String {
                    let reason = "Error \(status): \(name). \(message)"
                    completion(LiveUpdatesNetworkServiceError.api(reason: reason))
                    return
                }
                guard !jsonDictionary.isEmpty else {
                    let reason = "There are no languages in response"
                    completion(LiveUpdatesNetworkServiceError.parsing(reason: reason))
                    return
                }
                try parseJSON(jsonDictionary)
            } catch {
                let reason = error.localizedDescription
                completion(LiveUpdatesNetworkServiceError.dataBase(reason: reason))
            }
        }
        task.resume()
    }

    private static func configureLiveUpdating() {
        guard let url = ParseltongueRouter.getTranslations(appId).asURLRequest().url else { return }
        let socket = SocketIOClient(socketURL: url, config: [.log(false), .compress])
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }
        socket.on(appId) { data, ack in
            guard let json = data[0] as? JSONDictionary else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try parseJSON(json)
                } catch {
                    print("Could not parse received data from event: \(error.localizedDescription)")
                }
            }
            socket.emitWithAck("canUpdate", 0).timingOut(after: 0) { _ in
                socket.emit("updated")
            }
        }
        socket.connect()
    }

    private static func parseJSON(_ json: JSONDictionary) throws {
        try json.keys.forEach { key in
            if let languageDict = json[key] as? JSONDictionary {
                try addLocalizedTexts(json: languageDict, into: key)
            }
        }
    }

    private static func addLocalizedTexts(json: JSONDictionary, into language: String) throws {
        let localizedElements = json.flatMap { key, value -> LocalizedElement? in
            guard let text = value as? String else { return nil }
            return LocalizedElement(key: key, text: text)
        }
        let realm = try Realm(configuration: Realm.configuration(language: language))
        try realm.write { realm.add(localizedElements, update: true) }
    }
}
