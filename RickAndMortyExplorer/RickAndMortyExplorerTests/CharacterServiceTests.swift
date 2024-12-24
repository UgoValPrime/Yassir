//
//  CharacterServiceTests.swift
//  RickAndMortyExplorerTests
//
//  Created by GIGL-IT on 24/12/2024.
//

import XCTest
@testable import RickAndMortyExplorer

class CharacterServiceTests: XCTestCase {


    func testFetchCharacters_Success() {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let characterService = CharacterService(networkManager: mockNetworkManager)

        let mockResponse = CharacterResponse(
            info: Info(count: 2, pages: 1, next: nil, prev: nil),
            results: [
                Characterr(
                    id: 1,
                    name: "Rick Sanchez",
                    status: "Alive",
                    species: "Human",
                    type: "",
                    gender: "Male",
                    origin: Location(name: "Earth", url: ""),
                    location: Location(name: "Citadel of Ricks", url: ""),
                    image: "https://example.com/image1.jpg",
                    episode: [],
                    url: "",
                    created: ""
                ),
                Characterr(
                    id: 2,
                    name: "Morty Smith",
                    status: "Alive",
                    species: "Human",
                    type: "",
                    gender: "Male",
                    origin: Location(name: "Earth", url: ""),
                    location: Location(name: "Earth", url: ""),
                    image: "https://example.com/image2.jpg",
                    episode: [],
                    url: "",
                    created: ""
                )
            ]
        )

        mockNetworkManager.mockResult = .success(mockResponse)

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        characterService.fetchCharacters(page: 1, status: nil) { result in
            // Assert
            switch result {
            case .success(let response):
                XCTAssertEqual(response.results.count, 2)
                XCTAssertEqual(response.results[0].name, "Rick Sanchez")
                XCTAssertEqual(response.results[1].name, "Morty Smith")
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchCharacters_NetworkError() {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let characterService = CharacterService(networkManager: mockNetworkManager)

        mockNetworkManager.mockResult = .failure(NetworkError.serverError(statusCode: 500))

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        characterService.fetchCharacters(page: 1, status: nil) { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.serverError(statusCode: 500))
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchCharacters_WithStatusParameter() {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let characterService = CharacterService(networkManager: mockNetworkManager)

        let mockResponse = CharacterResponse(
            info: Info(count: 1, pages: 1, next: nil, prev: nil),
            results: [
                Characterr(
                    id: 1,
                    name: "Rick Sanchez",
                    status: "Alive",
                    species: "Human",
                    type: "",
                    gender: "Male",
                    origin: Location(name: "Earth", url: ""),
                    location: Location(name: "Citadel of Ricks", url: ""),
                    image: "https://example.com/image1.jpg",
                    episode: [],
                    url: "",
                    created: ""
                )
            ]
        )

        mockNetworkManager.mockResult = .success(mockResponse)

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        characterService.fetchCharacters(page: 1, status: "Alive") { result in
            // Assert
            switch result {
            case .success(let response):
                XCTAssertEqual(response.results.count, 1)
                XCTAssertEqual(response.results.first?.status, "Alive")
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}




class MockNetworkManager: NetworkManagerProtocol {
    var mockResult: Result<CharacterResponse, Error>?

    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let result = mockResult as? Result<T, Error> else {
            fatalError("Unexpected result type")
        }
        completion(result)
    }
}
