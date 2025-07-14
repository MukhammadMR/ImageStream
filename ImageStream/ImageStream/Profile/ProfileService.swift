import UIKit

final class ProfileService {
    static let shared = ProfileService()
    static let profileDidUpdateNotification = Notification.Name("ProfileServiceProfileDidUpdateNotification")

    private init() {}
    
    struct ProfileResult: Codable {
        let id: String
        let updatedAt: String
        let username: String
        let firstName: String
        let lastName: String
        let bio: String?

        enum CodingKeys: String, CodingKey {
            case id
            case updatedAt = "updated_at"
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }

        func withBio(_ newBio: String?) -> ProfileResult {
            return ProfileResult(
                id: self.id,
                updatedAt: self.updatedAt,
                username: self.username,
                firstName: self.firstName,
                lastName: self.lastName,
                bio: newBio
            )
        }

        func withFirstName(_ newFirstName: String) -> ProfileResult {
            return ProfileResult(
                id: self.id,
                updatedAt: self.updatedAt,
                username: self.username,
                firstName: newFirstName,
                lastName: self.lastName,
                bio: self.bio
            )
        }
    }
    
    struct Profile {
        let username : String
        let name : String
        let loginName: String
        let bio: String?
        
        init(profileResult: ProfileResult) {
            self.username = profileResult.username
            self.name = "\(profileResult.firstName) \(profileResult.lastName)"
            self.loginName = "@\(profileResult.username)"
            self.bio = profileResult.bio
        }
    }
    
    private(set) var profile: Profile?
    private var lastToken: String?

    private var task: URLSessionTask?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard lastToken != token else { return }
        lastToken = token
        guard let request = makeRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        self.task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self, token == self.lastToken else { return }
            self.lastToken = nil
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self.profile = profile
                NotificationCenter.default.post(name: ProfileService.profileDidUpdateNotification, object: nil)
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService][fetchProfile]: \(error.localizedDescription), token: \(token)")
                completion(.failure(error))
            }
        }
        self.task?.resume()
    }

    private func makeRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
