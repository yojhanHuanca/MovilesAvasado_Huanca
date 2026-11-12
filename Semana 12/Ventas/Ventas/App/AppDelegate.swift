import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        _ = CoreDataStack.shared
        DemoDataSeeder.seedIfNeeded()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        window?.makeKeyAndVisible()
        return true
    }

    func showMain(for user: Usuario) {
        window?.rootViewController = MainTabBarController(user: user)
    }

    func showLogin() {
        window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
    }
}
