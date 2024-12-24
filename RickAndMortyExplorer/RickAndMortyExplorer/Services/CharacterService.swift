//
//  CharacterService.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import Foundation

protocol CharacterServiceProtocol {
    func fetchCharacters(page: Int, status: String?, completion: @escaping (Result<CharacterResponse, Error>) -> Void)
}

class CharacterService: CharacterServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func fetchCharacters(page: Int, status: String?, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        var endpoint = "https://rickandmortyapi.com/api/character?page=\(page)"
        
        if let status = status?.lowercased() {
            endpoint += "&status=\(status)"
        }

        networkManager.request(endpoint: endpoint, method: .GET) { (result: Result<CharacterResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                print("Error: \(error.localizedDescription)") // Debugging information
                completion(.failure(error))
            }
        }
    }
}
