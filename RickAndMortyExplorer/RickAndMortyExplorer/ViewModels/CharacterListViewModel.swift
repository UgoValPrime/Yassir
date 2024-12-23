//
//  CharacterListViewModel.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import Foundation


class CharacterListViewModel {
    private let characterService: CharacterServiceProtocol
    private var currentPage: Int = 1
    private var isFetching: Bool = false
    var characters: [Characterr] = []
    var onError: ((String) -> Void)?
    var onCharactersFetched: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    init(characterService: CharacterServiceProtocol = CharacterService()) {
        self.characterService = characterService
    }

    func fetchCharacters() {
        guard !isFetching else { return }
        isFetching = true

        characterService.fetchCharacters(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            self.onLoadingStateChanged?(false) 

            switch result {
            case .success(let data):
                self.characters.append(contentsOf: data.results)
                self.currentPage += 1
                self.onCharactersFetched?()
                print(data.info)
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }

    var hasMorePages: Bool {
        return currentPage > 0
    }
}

