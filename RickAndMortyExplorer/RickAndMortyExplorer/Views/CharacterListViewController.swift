//
//  CharacterListViewController.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import UIKit
import SwiftUI
import Kingfisher

class CharacterListViewController: UIViewController {
    private let viewModel: CharacterListViewModel
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let noDataLabel = UILabel()

    init(viewModel: CharacterListViewModel = CharacterListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchCharacters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }



    private func setupUI() {
        view.backgroundColor = .white
        title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        

        // Filter Buttons
        let buttonTitles = ["Alive", "Dead", "Unknown"]
        let buttons = buttonTitles.enumerated().map { index, title -> UIButton in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
            button.backgroundColor = .clear
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.cornerRadius = 18 // Capsule shape
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            button.tag = index
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            return button
        }

        // Use a UIStackView to arrange the buttons proportionally
        let buttonStackView = UIStackView(arrangedSubviews: buttons)
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.alignment = .center
        buttonStackView.distribution = .equalSpacing // Dynamically adjusts spacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(UIScreen.main.bounds.width * 0.4)),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Activity Indicator
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

        // No Data Label
        noDataLabel.text = "No characters available."
        noDataLabel.textAlignment = .center
        noDataLabel.isHidden = true
        view.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func filterButtonTapped(_ sender: UIButton) {
        // Reset all buttons to default style
        guard let buttonStackView = sender.superview as? UIStackView else { return }
        for case let button as UIButton in buttonStackView.arrangedSubviews {
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.setTitleColor(.black, for: .normal)
        }

        // Highlight the selected button
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.setTitleColor(.systemBlue, for: .normal)

        // Update ViewModel's filter based on the selected button
        let selectedStatus: String
        switch sender.tag {
        case 0: selectedStatus = "alive"
        case 1: selectedStatus = "dead"
        case 2: selectedStatus = "unknown"
        default: selectedStatus = ""
        }

        viewModel.filterCharacters(by: selectedStatus)
        viewModel.fetchCharacters()
    }


    private func bindViewModel() {
        viewModel.onCharactersFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.noDataLabel.isHidden = !self!.viewModel.characters.isEmpty
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.activityIndicator.isHidden = !isLoading
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }

        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CharacterListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as? CharacterTableViewCell else {
            return UITableViewCell()
        }
        let character = viewModel.characters[indexPath.row]
        cell.configure(with: character)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCharacter = viewModel.characters[indexPath.row]

        // Map ViewModel character data to CharacterDetail
        let characterDetail = CharacterDetail(
            name: selectedCharacter.name,
            species: selectedCharacter.species,
            gender: selectedCharacter.gender,
            location: selectedCharacter.location.name,
            status: selectedCharacter.status,
            imageUrl: selectedCharacter.image
        )

        // Pass the character and image URL to showCharacterDetail
        showCharacterDetail(character: characterDetail, imageUrl: selectedCharacter.image)
        }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 {
            if viewModel.hasMorePages {
                viewModel.fetchCharacters()
            }
        }
    }
}




extension CharacterListViewController {
    func showCharacterDetail(character: CharacterDetail, imageUrl: String) {

        let cache = KingfisherManager.shared.cache
        
        cache.retrieveImage(forKey: imageUrl) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let cacheResult):
                    let cachedImage = cacheResult.image
                    
                    self.presentCharacterDetail(character: character, cachedImage: cachedImage)
                case .failure(let error):
                    print("Error retrieving cached image: \(error.localizedDescription)")
                    self.presentCharacterDetail(character: character, cachedImage: nil)
                }
            }
        }
    }
    
    @MainActor
    private func presentCharacterDetail(character: CharacterDetail, cachedImage: UIImage?) {
        let detailView = CharacterDetailView(character: character, cachedImage: cachedImage)
        let hostingController = UIHostingController(rootView: detailView)
        self.navigationController?.pushViewController(hostingController, animated: true)
    }
}



