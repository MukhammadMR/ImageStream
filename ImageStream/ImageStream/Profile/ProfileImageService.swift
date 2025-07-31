import Foundation

public protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    static var didChangeNotification: Notification.Name { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private init() {}
    private(set) var avatarURL: String?
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }

    private var task: URLSessionTask?
    private var lastUsername: String?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastUsername != username else { return }
        task?.cancel()
        lastUsername = username

        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("No token")
            return
        }

        var request = URLRequest(
            url: URL(string: "https://api.unsplash.com/users/\(username)")!
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
            case .failure(let error):
                print("[ProfileImageService][fetchProfileImageURL]: \(error.localizedDescription), username: \(username)")
                completion(.failure(error))
                self.lastUsername = nil
            }
        }
        self.task = task
        task.resume()
    }
    func reset() {
        avatarURL = nil
        lastUsername = nil
        task?.cancel()
        task = nil
    }
}
