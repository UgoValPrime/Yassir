//
//  CharacterTableViewCell.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import UIKit
import Kingfisher


class CharacterTableViewCell: UITableViewCell {

    // MARK: - UI Components
    let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkText
        return label
    }()

    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(characterImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(speciesLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false

        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            characterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            characterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 60),
            characterImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            speciesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            speciesLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            speciesLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }

    // MARK: - Configure Cell
    func configure(with character: Characterr) {
            nameLabel.text = character.name
            speciesLabel.text = character.species

            // Load image using Kingfisher
            if let url = URL(string: character.image) {
                characterImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholder"), // Add a placeholder image to your project
                    options: [
                        .transition(.fade(0.2)), // Smooth fade animation
                        .cacheOriginalImage // Cache the original image
                    ]
                )
            }

        // Set background color based on status
        switch character.status.lowercased() {
        case "alive":
            containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case "dead":
            containerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        default:
            containerView.backgroundColor = UIColor.clear
            containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
            containerView.layer.borderWidth = 1
        }
    }

    private func loadImage(from url: URL) {
        // Load image asynchronously
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.characterImageView.image = image
                }
            }
        }
    }
}

