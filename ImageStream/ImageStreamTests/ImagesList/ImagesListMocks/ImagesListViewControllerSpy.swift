
import Foundation
import UIKit
@testable import ImageStream

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var reloadRowCalled = false
    var showLikeErrorCalled = false
    var updateTableViewAnimatedCalled = false

    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
    }

    func showLikeError() {
        showLikeErrorCalled = true
    }

    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}

