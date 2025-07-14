import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let storage = OAuth2TokenStorage.shared
        
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
