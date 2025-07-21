
import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var isFetching = false
    private var lastLoadedPage: Int?

    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = (lastLoadedPage ?? 0) + 1

        let token = OAuth2TokenStorage.shared.token ?? ""

        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            isFetching = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else {
                self.isFetching = false
                print("Ошибка загрузки фото:", error ?? "Unknown error")
                return
            }

            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.isFetching = false
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                self.isFetching = false
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
    let color: String?
    let blurHash: String?
    let likes: Int?
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    let user: UserResult?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description, urls, user
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UserResult: Codable {
    let name: String?
    let username: String?
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


