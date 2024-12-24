//
//  File.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import Foundation

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}


struct Characterr: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Location
    let location: Location
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct Location: Codable {
    let name: String
    let url: String
}


struct CharacterResponse: Codable {
    let info: Info
    let results: [Characterr]
}



struct CharacterDetail {
    let name: String
    let species: String
    let gender: String
    let location: String
    let status: String
    let imageUrl: String
}
