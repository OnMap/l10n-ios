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

public class LiveUpdatingService {

    enum Constants {
        static let urlString = "https://parseltongue.onmap.co.il/v1/translations"
    }

    public static func setup(appId: String) {
        let url = URL(string: Constants.urlString + "?app_id=" + appId)!
        LiveUpdatingService.fetchAndParseAllLocalizedTexts(url: url)
        LiveUpdatingService.configureLiveUpdating(url: url, appId: appId)
    }

    private static func fetchAndParseAllLocalizedTexts(url: URL) {
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else { return }
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
            parseJSON(json)
        }
        task.resume()
    }

    private static func configureLiveUpdating(url: URL, appId: String) {
        let socket = SocketIOClient(socketURL: url, config: [.log(true), .compress])
        socket.on(clientEvent: .connect) { data, ack in
            print("socket connected")
        }
        socket.on(appId) { data, ack in
            guard let json = data[0] as? JSON else { return }
            parseJSON(json)
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
            let englishRealm = try? Realm(realmConfig: .english) {
            addLocalizedTexts(json: english, into: englishRealm)
        }
        if let hebrew = json["he"] as? JSON,
            let hebrewRealm = try? Realm(realmConfig: .hebrew) {
            addLocalizedTexts(json: hebrew, into: hebrewRealm)
        }
        if let russian = json["ru"] as? JSON,
            let russianRealm = try? Realm(realmConfig: .russian) {
            addLocalizedTexts(json: russian, into: russianRealm)
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
