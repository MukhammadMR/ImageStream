
import Foundation
import UIKit
@testable import ImageStream

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var didTapLikeCalled = false
    private(set) var didTapLikeIndexPath: IndexPath?
    private(set) var numberOfPhotosCalled = false
    private(set) var photoCalled = false
    private(set) var photoIndexPath: IndexPath?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
        didTapLikeIndexPath = indexPath
    }

    func numberOfPhotos() -> Int {
        numberOfPhotosCalled = true
        return 0
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photoCalled = true
        photoIndexPath = indexPath
        return Photo(id: "", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }
}
