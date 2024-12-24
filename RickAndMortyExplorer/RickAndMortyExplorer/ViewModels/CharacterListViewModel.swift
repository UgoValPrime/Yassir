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
    private var filterStatus: String?
    var characters: [Characterr] = []
    var onError: ((String) -> Void)?
    var onCharactersFetched: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    init(characterService: CharacterServiceProtocol = CharacterService()) {
        self.characterService = characterService
    }

    func fetchCharacters(reset: Bool = false) {
        guard !isFetching else { return }
        isFetching = true
        onLoadingStateChanged?(true)

        // Reset logic for new filters
        if reset {
            currentPage = 1
            characters = []
        }

        characterService.fetchCharacters(page: currentPage, status: filterStatus) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            self.onLoadingStateChanged?(false)

            switch result {
            case .success(let data):
                self.characters.append(contentsOf: data.results)
                self.currentPage += 1
                self.onCharactersFetched?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }

    func filterCharacters(by status: String) {
        filterStatus = status
        fetchCharacters(reset: true)
    }

    var hasMorePages: Bool {
        return !isFetching
    }
}
