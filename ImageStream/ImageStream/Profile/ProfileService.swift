import UIKit

final class ProfileService {
    static let shared = ProfileService()
    struct ProfileResult: Codable {
        var id: String
        var updated_at: String
        var username: String
        var first_name: String
        var last_name: String
        var twitter_username: String?
        var portfolio_url: String?
        var bio : String?
        var location : String?
        var total_likes : Int?
        var total_photos : Int?
        var total_collections : Int?
        var downloads : Int?
    }
    
    struct Profile {
        var username : String
        var name : String
        var loginName: String
        var bio: String?
        
        init(profileResult: ProfileResult) {
            self.username = profileResult.username
            self.name = "\(profileResult.first_name) \(profileResult.last_name)"
            self.loginName = "@\(profileResult.username)"
            self.bio = profileResult.bio
        }
    }
    
    private(set) var profile: Profile?
    private var lastToken: String?
    private var isFetching = false

    private func makeRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private var task: URLSessionTask?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        if isFetching {
            return
        }
        lastToken = token
        isFetching = true
        guard let request = makeRequest(token: token) else {
            isFetching = false
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        self.task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self, token == self.lastToken else { return }
            DispatchQueue.main.async {
                self.lastToken = nil
                self.isFetching = false
                switch result {
                case .success(let profileResult):
                    let profile = Profile(profileResult: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService][fetchProfile]: \(error.localizedDescription), token: \(token)")
                    completion(.failure(error))
                }
            }
        }
        self.task?.resume()
    }
}
