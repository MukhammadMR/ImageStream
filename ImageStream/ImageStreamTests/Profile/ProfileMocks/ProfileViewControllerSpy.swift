import ImageStream
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarImageCalled = false
    
    var receivedName: String?
    var receivedLogin: String?
    var receivedBio: String?
    var receivedAvatarURL: URL?
    
    func updateProfileDetails(name: String, login loginName: String, bio: String?) {
        updateProfileDetailsCalled = true
        receivedName = name
        receivedLogin = loginName
        receivedBio = bio
    }
    
    func updateAvatarImage(with url: URL) {
        updateAvatarImageCalled = true
        receivedAvatarURL = url
    }
}
