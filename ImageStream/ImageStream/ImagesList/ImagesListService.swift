
import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var isFetching = false
    private var currentPage = 0

    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        currentPage += 1

        let token = OAuth2TokenStorage.shared.token ?? ""

        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(currentPage)") else {
            isFetching = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            defer { self?.isFetching = false }

            guard let data = data, error == nil else {
                print("Ошибка загрузки фото:", error ?? "Unknown error")
                return
            }

            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }

                DispatchQueue.main.async {
                    self?.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодирования фото:", error)
            }
        }
        task.resume()
    }
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, description, urls
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool

    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        if let createdAtString = photoResult.createdAt {
            let formatter = ISO8601DateFormatter()
            self.createdAt = formatter.date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
}


