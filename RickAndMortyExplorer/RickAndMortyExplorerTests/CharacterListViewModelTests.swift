//
//  CharacterListViewModelTests.swift
//  RickAndMortyExplorerTests
//
//  Created by GIGL-IT on 24/12/2024.
//

import XCTest
@testable import RickAndMortyExplorer

// Mock CharacterService using MockNetworkManager
class MockCharacterService: CharacterServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func fetchCharacters(page: Int, status: String?, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        networkManager.request(endpoint: "", method: .GET, completion: completion)
    }
}

// Unit test class
class CharacterListViewModelTests: XCTestCase {
    var viewModel: CharacterListViewModel!
    var mockService: MockCharacterService!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockService = MockCharacterService(networkManager: mockNetworkManager)
        viewModel = CharacterListViewModel(characterService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    func testFetchCharactersSuccess() {
        let location = Location(name: "blast", url: "urllll")
        let expectedCharacters = [Characterr(id: 1, name: "sui", status: "Dead", species: "Human", type: "", gender: "male", origin: location, location: location, image: "testimage.com", episode: ["String","str2"], url: "url", created: "today")]
        let characterResponse = CharacterResponse(info: Info(count: 1, pages: 1, next: "", prev: nil), results: expectedCharacters)
        mockNetworkManager.mockResult = .success(characterResponse)

        let fetchExpectation = expectation(description: "fetchCharacters")

        viewModel.onCharactersFetched = {
            fetchExpectation.fulfill()
        }

        viewModel.fetchCharacters()

        wait(for: [fetchExpectation], timeout: 1.0)

        XCTAssertEqual(viewModel.characters.count, expectedCharacters.count)
        XCTAssertEqual(viewModel.characters.first?.name, "sui")
    }

    func testFetchCharactersFailure() {
        let expectedError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error"])
        mockNetworkManager.mockResult = .failure(expectedError)

        let errorExpectation = expectation(description: "onError")

        viewModel.onError = { error in
            XCTAssertEqual(error, expectedError.localizedDescription)
            errorExpectation.fulfill()
        }

        viewModel.fetchCharacters()

        wait(for: [errorExpectation], timeout: 1.0)
    }

    func testFilterCharacters() {
        let location = Location(name: "blast", url: "urllll")
        let expectedCharacters = [Characterr(id: 1, name: "sui", status: "Dead", species: "Human", type: "", gender: "male", origin: location, location: location, image: "testimage.com", episode: ["String","str2"], url: "url", created: "today")]
        let characterResponse = CharacterResponse(info: Info(count: 1, pages: 1, next: "", prev: nil), results: expectedCharacters)
        mockNetworkManager.mockResult = .success(characterResponse)

        let filterExpectation = expectation(description: "filterCharacters")

        viewModel.onCharactersFetched = {
            filterExpectation.fulfill()
        }

        viewModel.filterCharacters(by: "Alive")

        wait(for: [filterExpectation], timeout: 1.0)

        XCTAssertEqual(viewModel.characters.count, expectedCharacters.count)
        XCTAssertEqual(viewModel.characters.first?.name, "sui")
    }

}
