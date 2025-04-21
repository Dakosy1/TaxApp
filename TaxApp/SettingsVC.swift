//
//  SettingsVC.swift
//  TaxApp
//
//  Created by Нурдаулет Даулетхан on 20.04.2025.
//

import UIKit

class SettingsVC: UITableViewController {
    
    // MARK: - Properties
    private let sections = [
        NSLocalizedString("General", comment: "General section title"),
        NSLocalizedString("Language", comment: "Language section title")
    ]
    
    private let generalItems = [
        NSLocalizedString("Notifications", comment: "Notifications setting"),
        NSLocalizedString("Dark Mode", comment: "Dark Mode setting")
    ]
    
    private let languageItems = [
        NSLocalizedString("English", comment: "English language"),
        NSLocalizedString("Kazakh", comment: "Kazakh language")
    ]
    
    private var selectedLanguageIndex: Int {
        get {
            let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
            return language == "kk" ? 1 : 0
        }
        set {
            let languageCode = newValue == 0 ? "en" : "kk"
            UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
            // Применяем язык
            Bundle.setLanguage(languageCode)
            // Перезагружаем таб-бар для обновления локализации
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = MainTabBarController()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = NSLocalizedString("Settings", comment: "Settings title")
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return generalItems.count
        case 1: return languageItems.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.section {
        case 0: // General
            cell.textLabel?.text = generalItems[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "bell")
            } else {
                cell.imageView?.image = UIImage(systemName: "moon")
            }
            
        case 1: // Language
            cell.textLabel?.text = languageItems[indexPath.row]
            cell.accessoryType = indexPath.row == selectedLanguageIndex ? .checkmark : .none
            cell.imageView?.image = UIImage(systemName: "globe")
            
        default:
            break
        }
        
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.imageView?.tintColor = .systemGray
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // General
            if indexPath.row == 0 {
                // Переход на экран уведомлений (заглушка)
                let notificationsVC = UIViewController()
                notificationsVC.view.backgroundColor = .white
                notificationsVC.title = NSLocalizedString("Notifications", comment: "Notifications title")
                navigationController?.pushViewController(notificationsVC, animated: true)
            } else {
                // Переход на экран тёмного режима (заглушка)
                let darkModeVC = UIViewController()
                darkModeVC.view.backgroundColor = .white
                darkModeVC.title = NSLocalizedString("Dark Mode", comment: "Dark Mode title")
                navigationController?.pushViewController(darkModeVC, animated: true)
            }
            
        case 1: // Language
            selectedLanguageIndex = indexPath.row
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            
        default:
            break
        }
    }
}

// MARK: - Bundle Extension for Language Switching
extension Bundle {
    private static var languageSwizzled = false
    
    static func setLanguage(_ language: String) {
        if !languageSwizzled {
            languageSwizzled = true
            swizzleLocalization()
        }
        
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    private static func swizzleLocalization() {
        let originalMethod = class_getInstanceMethod(Bundle.self, #selector(Bundle.localizedString(forKey:value:table:)))
        let swizzledMethod = class_getInstanceMethod(Bundle.self, #selector(Bundle.customLocalizedString(forKey:value:table:)))
        if let original = originalMethod, let swizzled = swizzledMethod {
            method_exchangeImplementations(original, swizzled)
        }
    }
    
    @objc func customLocalizedString(forKey key: String, value: String?, table: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &AssociatedKeys.languageBundle) as? Bundle {
            return bundle.customLocalizedString(forKey: key, value: value, table: table)
        }
        
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")!
        let bundle = Bundle(path: path)!
        objc_setAssociatedObject(self, &AssociatedKeys.languageBundle, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bundle.customLocalizedString(forKey: key, value: value, table: table)
    }
}

private struct AssociatedKeys {
    static var languageBundle = "languageBundle"
}
