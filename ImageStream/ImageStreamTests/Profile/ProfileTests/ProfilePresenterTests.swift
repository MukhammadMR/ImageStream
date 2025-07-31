import XCTest
@testable import ImageStream

final class ProfilePresenterTests: XCTestCase {
    
    func testViewDidLoad_CallsUpdateMethods() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(),
            profileImageService: ProfileImageServiceStub()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(view.updateProfileDetailsCalled)
        XCTAssertTrue(view.updateAvatarImageCalled)
    }
    
    func testUpdateProfileDetails_UsesProfileData() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(),
            profileImageService: ProfileImageServiceStub()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.receivedName, "Stub User")
        XCTAssertEqual(view.receivedLogin, "@stubuser")
        XCTAssertEqual(view.receivedBio, "Stub biography")
    }
    
    func testUpdateAvatarImage_UsesCorrectURL() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(),
            profileImageService: ProfileImageServiceStub()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.receivedAvatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }
}
