//
//  NetworkManager.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(statusCode: Int)
    case timeout
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .noData:
            return "No data was returned by the server."
        case .decodingFailed:
            return "Failed to decode the response from the server."
        case .serverError(let statusCode):
            return "The server returned an error with status code \(statusCode)."
        case .timeout:
            return "The request timed out. Please check your internet connection and try again."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}


protocol NetworkManagerProtocol {
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

// MARK: - HTTPMethod Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}


class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager() // Singleton instance
    
    private var urlSession: URLSession

    // Default initializer uses `URLSession.shared`
    private init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // Convenience initializer for testing
    init(session: URLSession) {
        self.urlSession = session
    }

    // URL validation function
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        guard let scheme = url.scheme, ["http", "https"].contains(scheme) else {
            return false
        }
        
        guard url.host != nil else {
            return false
        }
        
        return true
    }

    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Validate URL
        guard isValidURL(endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Use the injected `URLSession`
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                if error.code == NSURLErrorTimedOut {
                    completion(.failure(NetworkError.timeout))
                } else {
                    completion(.failure(NetworkError.unknown))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(NetworkError.decodingFailed))
            }
        }

        task.resume()
    }
}
