//
//  CharacterService.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import Foundation

protocol CharacterServiceProtocol {
    func fetchCharacters(page: Int, completion: @escaping (Result<CharacterResponse, Error>) -> Void)
}


class CharacterService: CharacterServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func fetchCharacters(page: Int, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        let endpoint = "https://rickandmortyapi.com/api/character?page=\(page)"

        networkManager.request(endpoint: endpoint, method: .GET) { (result: Result<CharacterResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                // Print detailed error description for debugging
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
