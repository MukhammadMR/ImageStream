
import Foundation
import ImageStream

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String? = "https://example.com/avatar.jpg"
    static var didChangeNotification = Notification.Name("StubDidChangeNotification")
}
