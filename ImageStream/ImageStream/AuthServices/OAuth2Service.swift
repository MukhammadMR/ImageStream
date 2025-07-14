import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    private var currentCode: String?
    private var currentTask: URLSessionTask?
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create token URL")
            return
        }

        if currentTask != nil {
            print("Another token request is already in progress.")
            return
        }

        currentTask?.cancel()
        currentCode = code

        enum HTTPMethod: String {
            case post = "POST"
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        currentTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuth2Token, Error>) in
            guard let self = self else { return }
            self.currentTask = nil
            switch result {
            case .success(let tokenResponse):
                let tokenStorage = OAuth2TokenStorage.shared
                tokenStorage.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                print("[OAuth2Service][fetchOAuthToken]: \(error.localizedDescription), code: \(code)")
                completion(.failure(error))
            }
        }
        currentTask?.resume()
    }
}

struct OAuth2Token: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
