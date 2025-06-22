import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await self.data(for: request, delegate: nil)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.urlSessionError
        }
        if (200 ..< 300).contains(httpResponse.statusCode) {
            return (data, httpResponse)
        } else {
            throw NetworkError.httpStatusCode(httpResponse.statusCode)
        }
    }
}
