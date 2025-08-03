import XCTest
@testable import ImageStream

final class ImagesListViewControllerTests: XCTestCase {

    func testViewDidLoad_CallsPresenterViewDidLoad() {
        let presenter = ImagesListPresenterSpy()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter

        sut.loadViewIfNeeded()

        XCTAssertTrue(presenter.viewDidLoadCalled, "Expected viewDidLoad to be called")
    }

    func testDidTapLike_CallsPresenterDidTapLikeWithCorrectIndexPath() {
        let presenter = ImagesListPresenterSpy()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter
        let indexPath = IndexPath(row: 0, section: 0)

        sut.imageListCellDidTapLike(ImagesListCell(), forRowAt: indexPath)

        XCTAssertTrue(presenter.didTapLikeCalled, "Expected didTapLike to be called")
        XCTAssertEqual(presenter.didTapLikeIndexPath, indexPath, "Expected correct indexPath to be passed")
    }

    func testNumberOfPhotos_CallsPresenterNumberOfPhotos() {
        let presenter = ImagesListPresenterSpy()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter

        _ = sut.numberOfPhotos()

        XCTAssertTrue(presenter.numberOfPhotosCalled, "Expected numberOfPhotos to be called")
    }

    func testPhotoForIndexPath_CallsPresenterPhoto() {
        let presenter = ImagesListPresenterSpy()
        let sut = ImagesListViewControllerSpy()
        sut.presenter = presenter
        let indexPath = IndexPath(row: 1, section: 0)

        _ = sut.photo(at: indexPath)

        XCTAssertTrue(presenter.photoCalled, "Expected photo to be called")
        XCTAssertEqual(presenter.photoIndexPath, indexPath, "Expected correct indexPath to be passed")
    }

    func testReloadRow_CallsPresenterReloadRow() {
        let sut = ImagesListViewControllerSpy()
        let indexPath = IndexPath(row: 0, section: 0)

        sut.reloadRow(at: indexPath)

        XCTAssertEqual(sut.reloadRowCalledWith, indexPath, "Expected reloadRow to be called with correct indexPath")
    }

    func testUpdateTableViewAnimated_CallsPresenterUpdateTableViewAnimated() {
        let sut = ImagesListViewControllerSpy()

        sut.updateTableViewAnimated()

        XCTAssertTrue(sut.isUpdateTableViewAnimatedCalled, "Expected updateTableViewAnimated to be called")
    }
}
