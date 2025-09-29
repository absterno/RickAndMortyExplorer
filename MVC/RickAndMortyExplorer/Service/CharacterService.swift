//
//  CharacterService.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import Foundation
import RickMortySwiftApi

final class CharacterService {
    private let client: RMClient
    
    init(client: RMClient = RMClient()) {
        self.client = client
    }
    
    func fetchAllCharacters() async throws -> [RMCharacterModel] {
        try await client.character().getAllCharacters()
    }
    
    func fetchEpisodes(for character: RMCharacterModel) async throws -> [RMEpisodeModel] {
        let episodeIDs = character.episode
            .compactMap { URL(string: $0)?.lastPathComponent }
            .compactMap(Int.init)
        
        guard !episodeIDs.isEmpty else { return [] }
        
        let response = try await client.episode().getEpisodesByIDs(ids: episodeIDs)
        return response.sorted { $0.episode < $1.episode }
    }
}
