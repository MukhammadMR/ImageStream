import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void)
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func reset()
}

final class ImagesListService: ImagesListServiceProtocol {
    private let decoder = JSONDecoder()
    private init() {}
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []

    private var isFetching = false
    private var lastLoadedPage: Int?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    func fetchPhotosNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = (lastLoadedPage ?? 0) + 1

        let token = OAuth2TokenStorage.shared.token ?? ""

        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            isFetching = false
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else {
                self.isFetching = false
                completion(.failure(error ?? NSError(domain: "Unknown error", code: 0)))
                return
            }

            do {
                let photoResults = try self.decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.isFetching = false
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    completion(.success(()))
                }
            } catch {
                self.isFetching = false
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let token = OAuth2TokenStorage.shared.token?.description ?? ""
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                completion(.success(()))
            }
        }
        task.resume()
    }
    func reset() {
        photos = []
        lastLoadedPage = nil
        isFetching = false
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
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
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
            let formatter = Self.dateFormatter
            self.createdAt = formatter.date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
    
    init(
        id: String,
        size: CGSize,
        createdAt: Date?,
        welcomeDescription: String?,
        thumbImageURL: String,
        largeImageURL: String,
        isLiked: Bool
    ) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}
