//
//  LanguageSelectVC.swift
//  LocalizationExample
//
//  Created by Philip Kramer on 24/12/2016.
//  Copyright © 2016 OnMap LTD. All rights reserved.
//

import UIKit
import OML10n

class LanguageSelectVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBAction func pressedSave(_ sender: Any) {
        if let selectedIndex = tableView.indexPathForSelectedRow?.row {
            let selectedLanguage = Localization.availableLanguages[selectedIndex]
            Localization.currentLanguage = selectedLanguage
            _ = navigationController?.popViewController(animated: true)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.launchStoryboard(.main)
            } else {
                assertionFailure()
            }
        } else {
            assertionFailure()
        }
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension LanguageSelectVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Localization.availableLanguages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentLanguage = Localization.availableLanguages[indexPath.row]
        if Localization.currentLanguage == currentLanguage {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = Localization
            .displayNameForLanguage(currentLanguage, inLanguge: currentLanguage)

        return cell
    }
}

extension LanguageSelectVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}
