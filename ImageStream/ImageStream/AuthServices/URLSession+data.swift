import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case noData
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
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[objectTask]: urlRequestError - \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[objectTask]: urlSessionError - response is nil")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                guard let data = data else {
                    print("[objectTask]: noData")
                    completion(.failure(NetworkError.noData))
                    return
                }
                if (200 ..< 300).contains(httpResponse.statusCode) {
                    let decoder = JSONDecoder()
                    do {
                        let object = try decoder.decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
                        print("[objectTask]: Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                        completion(.failure(error))
                    }
                } else {
                    print("[objectTask]: httpStatusCode - \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            }
        }
        return task
    }
}
