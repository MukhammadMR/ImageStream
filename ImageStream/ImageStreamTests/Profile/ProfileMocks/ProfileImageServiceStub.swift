import Foundation
import ImageStream

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String? = "https://example.com/avatar.jpg"
    static var didChangeNotification = Notification.Name("StubDidChangeNotification")
    
    func fetchProfileImageURL(username token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if let url = avatarURL {
            completion(.success(url))
        } else {
            completion(.failure(NSError(domain: "Stub", code: -1, userInfo: nil)))
        }
    }
}
