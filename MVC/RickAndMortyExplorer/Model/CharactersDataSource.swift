//
//  CharactersDataSource.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import RickMortySwiftApi

final class CharactersDataSource {
    private(set) var characters: [RMCharacterModel] = []
    private(set) var filteredCharacters: [RMCharacterModel] = []
    private(set) var currentQuery: String? = nil
    private(set) var currentStatus: String? = nil
    
    var onDataChanged: (() -> Void)?

    func update(with characters: [RMCharacterModel]) {
        self.characters = characters
        applyFilters()
    }

    func applyFilters(query: String? = nil, status: String? = nil) {
        // обновляем активные фильтры
        if let query = query {
            currentQuery = query.isEmpty ? nil : query.lowercased()
        }
        if let status = status {
            currentStatus = status
        }

        var temp = characters

        // фильтр по статусу
        if let status = currentStatus {
            temp = temp.filter { $0.status.lowercased() == status.lowercased() }
        }

        // фильтр по имени
        if let query = currentQuery {
            temp = temp.filter { $0.name.lowercased().contains(query) }
        }

        filteredCharacters = temp
        onDataChanged?()
    }

    func setCurrentStatus(_ status: String?) {
        currentStatus = status
        applyFilters(status: status)
    }

}
