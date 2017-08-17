//
//  LiveUpdatingService.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 17/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import Foundation
import RealmSwift
import SocketIO

typealias JSON = [String: Any]

class LiveUpdatingService {

    enum Constants {
        static let appId = "20ed5867-d32c-4d34-b8b7-4dcb8d48f79b"
        static let url = URL(string: "http://localhost:3030/v1/translations?app_id=\(Constants.appId)")!
    }

    static func setup() {
        LiveUpdatingService.fetchAndParseAllLocalizedTexts()
        LiveUpdatingService.configureLiveUpdating()
    }

    private static func fetchAndParseAllLocalizedTexts() {
        let urlRequest = URLRequest(url: Constants.url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else { return }
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
            LiveUpdatingService.parseJSON(json)
        }
        task.resume()
    }

    private static func configureLiveUpdating() {
        let socket = SocketIOClient(socketURL: Constants.url, config: [.log(true), .compress])
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }
        socket.on(Constants.appId) { data, ack in
            guard let json = data[0] as? JSON else { return }
            LiveUpdatingService.parseJSON(json)
            if let cur = data[0] as? Double {
                socket.emitWithAck("canUpdate", cur).timingOut(after: 0) { data in
                    socket.emit("update", ["amount": cur + 2.50])
                }
                ack.with("Got your currentAmount", "dude")
            }
        }
        socket.connect()
    }

    private static func parseJSON(_ json: JSON) {
        if let english = json["en"] as? JSON,
            let englishRealm = try? Realm(configuration: RealmConfig.englishLocalization.configuration) {
            LiveUpdatingService.addLocalizedTexts(json: english, into: englishRealm)
        }
        if let hebrew = json["he"] as? JSON,
            let hebrewRealm = try? Realm(configuration: RealmConfig.hebrewLocalization.configuration) {
            LiveUpdatingService.addLocalizedTexts(json: hebrew, into: hebrewRealm)
        }
        if let russian = json["ru"] as? JSON,
            let russianRealm = try? Realm(configuration: RealmConfig.russianLocalization.configuration) {
            LiveUpdatingService.addLocalizedTexts(json: russian, into: russianRealm)
        }
    }

    private static func addLocalizedTexts(json: JSON, into realm: Realm) {
        let localizedTexts = json.flatMap { key, value -> LocalizedText? in
            guard let text = value as? String else { return nil }
            return LocalizedText(key: key, text: text)
        }
        do {
            try realm.write { realm.add(localizedTexts, update: true) }
        } catch {
            print(error.localizedDescription)
        }
    }
}
