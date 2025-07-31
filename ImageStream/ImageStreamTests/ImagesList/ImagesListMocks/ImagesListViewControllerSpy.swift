import Foundation
import UIKit
@testable import ImageStream

final class ImagesListViewControllerSpy: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var tableView = UITableView()
    
    var reloadRowCalled = false
    var reloadRowCalledWith: IndexPath?
    var showLikeErrorCalled = false
    var updateTableViewAnimatedCalled = false
    var showBlockingLoadingCalled = false
    var hideBlockingLoadingCalled = false

    var isUpdateTableViewAnimatedCalled: Bool {
        return updateTableViewAnimatedCalled
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        reloadRowCalledWith = indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func showLikeError() {
        showLikeErrorCalled = true
    }

    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell, forRowAt indexPath: IndexPath) {
        presenter?.didTapLike(at: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfPhotos() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        _ = presenter?.photo(at: indexPath)
        return UITableViewCell()
    }

    func numberOfPhotos() -> Int {
        return tableView(tableView, numberOfRowsInSection: 0)
    }

    func photo(at indexPath: IndexPath) -> Photo {
        _ = tableView(tableView, cellForRowAt: indexPath)
        return presenter?.photo(at: indexPath) ?? Photo(id: "", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }
    
    func showBlockingLoading() {
        showBlockingLoadingCalled = true
    }

    func hideBlockingLoading() {
        hideBlockingLoadingCalled = true
    }
}

