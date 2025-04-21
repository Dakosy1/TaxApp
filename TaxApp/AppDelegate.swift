import UIKit
import FirebaseCore
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        FirebaseApp.configure()
        window?.rootViewController = UINavigationController(rootViewController: MainTabBarController())
        window?.makeKeyAndVisible()
        // Override point for customization after application launch.
        return true
    }
}
