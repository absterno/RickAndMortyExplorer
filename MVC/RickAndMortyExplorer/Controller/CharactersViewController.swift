//
//  CharactersViewController.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import UIKit
import SwiftUI
import RickMortySwiftApi

final class CharactersViewController: UIViewController {
    private var collectionView: UICollectionView
    private var searchBar: UISearchBar
    private var filterButton: UIButton

    private var selectedCharacter: RMCharacterModel?

    private let dataSource: CharactersDataSource
    private let characterService: CharacterService
    private let imageService: ImageService

    init(
        dataSource: CharactersDataSource = CharactersDataSource(),
        characterService: CharacterService = CharacterService(),
        imageService: ImageService = ImageService()
    ) {
        self.dataSource = dataSource
        self.characterService = characterService
        self.imageService = imageService
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        searchBar = UISearchBar()
        filterButton = UIButton(type: .system)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rick & Morty Explorer"
        view.backgroundColor = .systemBackground

        setupSearchBar()
        setupFilterButton()
        setupCollectionView()
        fetchCharacters()
        
        dataSource.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateFilterMenu()
        }
        navigationController?.delegate = self
    }

    // MARK: - UI Setup
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search by name"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36)
        ])
    }

    private func setupFilterButton() {
        filterButton.backgroundColor = .white
        filterButton.tintColor = .systemGray
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)

        NSLayoutConstraint.activate([
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 24),
            filterButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        updateFilterMenu()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateFilterMenu() {
        let statuses: [(title: String, value: String?)] = [
            ("All", nil),
            ("Alive", "Alive"),
            ("Dead", "Dead"),
            ("Unknown", "unknown")
        ]

        let actions = statuses.map { item in
            UIAction(
                title: item.title,
                state: (dataSource.currentStatus == item.value) ? .on : .off,
                handler: { [weak self] _ in
                    self?.dataSource.setCurrentStatus(item.value)
                }
            )
        }

        filterButton.menu = UIMenu(title: "Filter by status", options: .singleSelection, children: actions)
        filterButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - Data
    private func fetchCharacters() {
        Task {
            do {
                let chars = try await characterService.fetchAllCharacters()
                self.dataSource.update(with: chars)
            } catch {
                print("Ошибка загрузки: \(error)")
                // можно показать ошибку UI
            }
        }
    }

    private func fetchEpisodes(for character: RMCharacterModel, completion: @escaping ([RMEpisodeModel], String?) -> Void) {
        Task {
            do {
                let eps = try await characterService.fetchEpisodes(for: character)
                completion(eps, nil)
            } catch {
                completion([], error.localizedDescription)
            }
        }
    }
}

// MARK: - Collection DataSource
extension CharactersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.filteredCharacters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCell.identifier,
            for: indexPath
        ) as? CharacterCell else {
            return UICollectionViewCell()
        }

        let character = dataSource.filteredCharacters[indexPath.item]
        
        // Загружаем изображение через сервис
        imageService.loadImage(from: character.image) { [weak self] image in
            guard let self = self else { return }

            // проверяем, что персонаж всё ещё на этом indexPath
            if let currentIndex = self.dataSource.filteredCharacters.firstIndex(where: { $0.id == character.id }),
               currentIndex == indexPath.item {
                DispatchQueue.main.async {
                    cell.image = image
                }
            }
        }
        
        cell.configure(name: character.name, status: character.status)
        return cell
    }
}

// MARK: - Collection Delegate
extension CharactersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = dataSource.filteredCharacters[indexPath.item]
        selectedCharacter = character

        // Считаем frame выбранной ячейки
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let cellFrame = collectionView.convert(cell.frame, to: view)

        // Передаём frame в HeroNavigationController
        if let nav = navigationController as? HeroNavigationController {
            nav.originFrame = cellFrame
        }
        
        // Загружаем эпизоды, затем создаём детальный экран и пушим
        // Передаём данные в SwiftUI-вью (View) — контроллер отвечает за загрузку (Controller)
        fetchEpisodes(for: character) { [weak self] episodes, errorMessage in
            DispatchQueue.main.async {
                let detailView = CharacterDetailView(
                    character: character,
                    episodes: episodes,
                    isLoading: episodes.isEmpty && errorMessage == nil,
                    errorMessage: errorMessage
                )
                let hostingVC = UIHostingController(rootView: detailView)
                self?.navigationController?.pushViewController(hostingVC, animated: true)
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate (HeroTransition)
extension CharactersViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let selectedCharacter = selectedCharacter else { return nil }

        guard let index = dataSource.filteredCharacters.firstIndex(where: { $0.id == selectedCharacter.id }) else { return nil }
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        collectionView.layoutIfNeeded()
        guard let cell = collectionView.cellForItem(at: indexPath) as? CharacterCell else { return nil }

        let cellFrame = collectionView.convert(cell.frame, to: view)
        let cellImage = cell.image

        return HeroTransition(presenting: operation == .push, originFrame: cellFrame, originImage: cellImage)
    }
}

// MARK: - FlowLayout Delegate
extension CharactersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8
        let spacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - padding * 2
        let minItemWidth: CGFloat = 180
        let itemsPerRow = max(Int(availableWidth / (minItemWidth + spacing)), 1)
        let totalSpacing = CGFloat(itemsPerRow - 1) * spacing
        let itemWidth = floor((availableWidth - totalSpacing) / CGFloat(itemsPerRow))
        return CGSize(width: itemWidth, height: itemWidth + 64)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

// MARK: - SearchBar Delegate
extension CharactersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource.applyFilters(query: searchBar.text)
    }
}
