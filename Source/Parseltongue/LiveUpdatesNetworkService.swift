//
//  LiveUpdatesNetworkService.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 17/08/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift
import SocketIO

typealias JSONDictionary = [String: Any]

public class LiveUpdatesNetworkService {

    private static var appId: String!
    private static var token: String!

    // MARK: - Public

    public static func setup(appId: String, token: String) {
        LiveUpdatesNetworkService.appId = appId
        LiveUpdatesNetworkService.token = token
        deleteExistingRealms()
        fetchAndParseAllLocalizedTexts()
        configureLiveUpdating()
    }

    static func postKeys(_ keys: [String]) {
        let urlRequest = ParceltongueRouter.postKeys(appId: appId, keys: keys, token: token).asURLRequest()
        let task = URLSession.shared.dataTask(with: urlRequest) { _, _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

    // MARK: - Private

    private static func deleteExistingRealms() {
        [RealmConfig.english, RealmConfig.hebrew, RealmConfig.russian].forEach { $0.delete() }
    }

    private static func fetchAndParseAllLocalizedTexts() {
        let urlRequest = ParceltongueRouter.getTranslations(appId).asURLRequest()
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else {
                print("There is no data in response")
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = jsonObject as? JSONDictionary else {
                    print("Returned object is not a json dictionary:\n\(jsonObject)")
                    return
                }
                if let status = jsonDictionary["status"] as? Int,
                    let name = jsonDictionary["name"] as? String,
                    let message = jsonDictionary["message"] as? String {
                    print("Error \(status): \(name). \(message)")
                    return
                }
                try parseJSON(jsonDictionary)
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

    private static func configureLiveUpdating() {
        guard let url = ParceltongueRouter.getTranslations(appId).asURLRequest().url else { return }
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
        if let english = json["en"] as? JSONDictionary {
            try addLocalizedTexts(json: english, into: .english)
        }
        if let hebrew = json["he"] as? JSONDictionary {
            try addLocalizedTexts(json: hebrew, into: .hebrew)
        }
        if let russian = json["ru"] as? JSONDictionary {
            try addLocalizedTexts(json: russian, into: .russian)
        }
    }

    private static func addLocalizedTexts(json: JSONDictionary, into realmConfig: RealmConfig) throws {
        let localizedElements = json.flatMap { key, value -> LocalizedElement? in
            guard let text = value as? String else { return nil }
            return LocalizedElement(key: key, text: text)
        }
        let realm = try Realm(realmConfig: realmConfig)
        try realm.write { realm.add(localizedElements, update: true) }
    }
}
