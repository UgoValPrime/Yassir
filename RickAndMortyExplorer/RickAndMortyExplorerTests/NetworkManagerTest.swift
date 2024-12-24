////
////  NetworkManagerTest.swift
////  RickAndMortyExplorerTests
////
////  Created by GIGL-IT on 24/12/2024.
////

import XCTest
@testable import RickAndMortyExplorer

class NetworkManagerTests: XCTestCase {
    var sut: NetworkManager! // System Under Test
    var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        sut = NetworkManager(session: mockURLSession) // Inject the mock session
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }

    func testRequest_withValidResponse_shouldReturnDecodedObject() {
        // Arrange
        let mockData = """
        {
        "info": {
        "count": 826,
        "pages": 42,
        "next": "https://rickandmortyapi.com/api/character?page=3",
        "prev": "https://rickandmortyapi.com/api/character?page=1"
        },
        "results": [
        {
        "id": 21,
        "name": "Aqua Morty",
        "status": "unknown",
        "species": "Humanoid",
        "type": "Fish-Person",
        "gender": "Male",
        "origin": {
        "name": "unknown",
        "url": ""
        },
        "location": {
        "name": "Citadel of Ricks",
        "url": "https://rickandmortyapi.com/api/location/3"
        },
        "image": "https://rickandmortyapi.com/api/character/avatar/21.jpeg",
        "episode": [
        "https://rickandmortyapi.com/api/episode/10",
        "https://rickandmortyapi.com/api/episode/22"
        ],
        "url": "https://rickandmortyapi.com/api/character/21",
        "created": "2017-11-04T22:39:48.055Z"
        }
        ]
        }
        """.data(using: .utf8)!
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        sut.request(endpoint: "https://example.com", method: .GET) { (result: Result<CharacterResponse, Error>) in
            // Assert
            switch result {
              
            case .success(let model):
                for char in model.results {
                    XCTAssertEqual(char.id, 21)
                    XCTAssertEqual(char.name, "Aqua Morty")
                }
               
            case .failure:
                XCTFail("Expected success, got failure instead")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequest_withInvalidURL_shouldReturnInvalidURLError() {
        // Arrange
        let expectation = self.expectation(description: "Completion handler called")

        // Act
        sut.request(endpoint: "invalid_url", method: .GET) { (result: Result<Characterr, Error>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.invalidURL)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequest_withServerError_shouldReturnServerError() {
        // Arrange
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        sut.request(endpoint: "https://example.com", method: .GET) { (result: Result<Characterr, Error>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                if case NetworkError.serverError(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)
                } else {
                    XCTFail("Expected serverError, got \(error) instead")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequest_withNoData_shouldReturnNoDataError() {
        // Arrange
        mockURLSession.mockData = nil
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        sut.request(endpoint: "https://example.com", method: .GET) { (result: Result<Characterr, Error>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.noData)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequest_withDecodingError_shouldReturnDecodingError() {
        // Arrange
        let invalidMockData = """
        { "invalidKey": "Invalid Value" }
        """.data(using: .utf8)!
        mockURLSession.mockData = invalidMockData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        sut.request(endpoint: "https://example.com", method: .GET) { (result: Result<Characterr, Error>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.decodingFailed)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRequest_withTimeout_shouldReturnTimeoutError() {
        // Arrange
        let timeoutError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        mockURLSession.mockError = timeoutError

        let expectation = self.expectation(description: "Completion handler called")

        // Act
        sut.request(endpoint: "https://example.com", method: .GET) { (result: Result<Characterr, Error>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, got success instead")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.timeout)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}





class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        
        print("Returning mockData: \(String(data: mockData ?? Data(), encoding: .utf8) ?? "nil")")
        return MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}
