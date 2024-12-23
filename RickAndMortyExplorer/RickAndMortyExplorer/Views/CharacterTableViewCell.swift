//
//  CharacterTableViewCell.swift
//  RickAndMortyExplorer
//
//  Created by GIGL-IT on 22/12/2024.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let speciesLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        characterImageView.contentMode = .scaleAspectFit
        characterImageView.layer.cornerRadius = 8
        characterImageView.clipsToBounds = true
        characterImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        speciesLabel.font = .systemFont(ofSize: 14)
        speciesLabel.textColor = .gray
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [nameLabel, speciesLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(characterImageView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            characterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 60),
            characterImageView.heightAnchor.constraint(equalToConstant: 60),

            stackView.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with character: Characterr) {
        nameLabel.text = character.name
        speciesLabel.text = character.species
        if let url = URL(string: character.image) {
            // Use your preferred image loading library (e.g., SDWebImage or Kingfisher)
            // Example: characterImageView.sd_setImage(with: url)
        }
    }
}
