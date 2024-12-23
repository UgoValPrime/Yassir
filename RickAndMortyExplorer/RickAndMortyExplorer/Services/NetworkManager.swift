//
//  NetworkManager.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import Foundation

enum NetworkError: Error, LocalizedError {
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
    private init() {}

    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Validate URL
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add headers (if needed)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error as NSError? {
                if error.code == NSURLErrorTimedOut {
                    completion(.failure(NetworkError.timeout))
                } else {
                    completion(.failure(NetworkError.unknown))
                }
                return
            }

            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
                    return
                }
            }

            // Ensure data is present
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            // Decode the data
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(NetworkError.decodingFailed))
            }
        }

        // Start the network request
        task.resume()
    }
}
