
import Foundation
import ImageStream

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile? = Profile(
        username: "stub_user",
        name: "Stub User",
        loginName: "@stubuser",
        bio: "Stub biography"
    )
}
