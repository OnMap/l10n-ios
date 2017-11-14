//
//  LiveUpdatingService.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 17/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import Foundation
import RealmSwift
import SocketIO

typealias JSONDictionary = [String: Any]

public class LiveUpdatingService {

    private enum Constants {
        static let urlString = "https://parseltongue.onmap.co.il/v1/translations"
    }

    // MARK: - Public

    public static func setup(appId: String) {
        deleteExistingRealms()
        let url = URL(string: Constants.urlString + "?app_id=" + appId)!
        fetchAndParseAllLocalizedTexts(url: url)
        configureLiveUpdating(url: url, appId: appId)
    }

    // MARK: - Private

    private static func deleteExistingRealms() {
        [RealmConfig.english, RealmConfig.hebrew, RealmConfig.russian].forEach { $0.delete() }
    }

    private static func fetchAndParseAllLocalizedTexts(url: URL) {
        let urlRequest = URLRequest(url: url)
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
                if let jsonDictionary = jsonObject as? JSONDictionary {
                    parseJSON(jsonDictionary)
                } else {
                    print("Returned object is not a json dictionary:\n\(jsonObject)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

    private static func configureLiveUpdating(url: URL, appId: String) {
        let socket = SocketIOClient(socketURL: url, config: [.log(false), .compress])
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }
        socket.on(appId) { data, ack in
            guard let json = data[0] as? JSONDictionary else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                parseJSON(json)
            }
            socket.emitWithAck("canUpdate", 0).timingOut(after: 0) { _ in
                socket.emit("updated")
            }
        }
        socket.connect()
    }

    private static func parseJSON(_ json: JSONDictionary) {
        if let english = json["en"] as? JSONDictionary,
            let englishRealm = try? Realm(realmConfig: .english) {
            addLocalizedTexts(json: english, into: englishRealm)
        }
        if let hebrew = json["he"] as? JSONDictionary,
            let hebrewRealm = try? Realm(realmConfig: .hebrew) {
            addLocalizedTexts(json: hebrew, into: hebrewRealm)
        }
        if let russian = json["ru"] as? JSONDictionary,
            let russianRealm = try? Realm(realmConfig: .russian) {
            addLocalizedTexts(json: russian, into: russianRealm)
        }
    }

    private static func addLocalizedTexts(json: JSONDictionary, into realm: Realm) {
        let localizedElements = json.flatMap { key, value -> LocalizedElement? in
            guard let text = value as? String else { return nil }
            return LocalizedElement(key: key, text: text)
        }
        do {
            try realm.write { realm.add(localizedElements, update: true) }
        } catch {
            print(error.localizedDescription)
        }
    }
}
