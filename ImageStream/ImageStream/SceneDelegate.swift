import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let storage = OAuth2TokenStorage.shared
        NotificationCenter.default.addObserver(
            forName: .didLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.switchToSplashController()
        }
        
        print("Token at launch: \(String(describing: storage.token))")

        if let token = storage.token, !token.isEmpty {
            let tabBarController = TabBarController()
            window.rootViewController = tabBarController
        } else {
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
        }
        self.window = window
        window.makeKeyAndVisible()
    }

}

extension SceneDelegate {
    func switchToSplashController() {
        guard let window = self.window else { return }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
}

extension Notification.Name {
    static let didLogout = Notification.Name("didLogout")
}

