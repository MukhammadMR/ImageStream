import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLike(at indexPath: IndexPath)
    func numberOfPhotos() -> Int
    func photo(at indexPath: IndexPath) -> Photo
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol

    init(view: ImagesListViewControllerProtocol, imagesListService: ImagesListServiceProtocol) {
        self.view = view
        self.imagesListService = imagesListService
    }

    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage(completion: { [weak self] (result: Result<Void, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.view?.updateTableViewAnimated()
                case .failure(let error):
                    print("Ошибка загрузки фотографий: \(error)")
                }
            }
        })
    }

    func numberOfPhotos() -> Int {
        return imagesListService.photos.count
    }

    func photo(at indexPath: IndexPath) -> Photo {
        return imagesListService.photos[indexPath.row]
    }

    func didTapLike(at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        view?.showBlockingLoading()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideBlockingLoading()
                switch result {
                case .success:
                    self?.view?.reloadRow(at: indexPath)
                case .failure(let error):
                    self?.view?.showLikeError()
                    print("Ошибка при лайке: \(error)")
                }
            }
        }
    }
}
