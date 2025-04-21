import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
            
        let mainVC = UINavigationController(rootViewController: MainViewController())
        mainVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Home", comment: "Home tab title"), image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let settingsVC = UINavigationController(rootViewController: SettingsVC())
        settingsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: "Settings tab title"), image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.fill"))
        
        let chatBotVC = UINavigationController(rootViewController: ChatViewInteractionWithSwiftUI())
        chatBotVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Chat", comment: "Chat tab title"), image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message.fill"))
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: "Profile tab title"), image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
//        let historyVC = UINavigationController(rootViewController: HistoryViewController())
//        historyVC.tabBarItem = UITabBarItem(title: NSLocalizedString("History", comment: "History tab title"), image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        
        let tabBarList = [mainVC, chatBotVC, settingsVC, /*historyVC*/ profileVC]
        viewControllers = tabBarList
        
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .white
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
