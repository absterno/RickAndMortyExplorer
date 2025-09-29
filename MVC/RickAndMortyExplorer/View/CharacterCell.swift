//
//  Untitled.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import UIKit

class CharacterCell: UICollectionViewCell {
    static let identifier = "CharacterCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 16)
        lbl.numberOfLines = 2
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
        
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 2
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        nameLabel.text = nil
        statusLabel.text = nil
    }

    func configure(name: String, status: String, image: UIImage? = nil) {
        nameLabel.text = name

        // Цветовая схема + иконки
        switch status {
        case "Alive":
            statusLabel.text = "🟢 Alive"
            statusLabel.textColor = UIColor.white
            contentView.backgroundColor = UIColor(red: 0.15, green: 0.7, blue: 0.3, alpha: 1)
            contentView.layer.borderColor = UIColor.green.cgColor

        case "Dead":
            statusLabel.text = "💀 Dead"
            statusLabel.textColor = UIColor.white
            contentView.backgroundColor = UIColor(red: 0.85, green: 0.1, blue: 0.25, alpha: 1)
            contentView.layer.borderColor = UIColor.red.cgColor

        default:
            statusLabel.text = "❔ Unknown"
            statusLabel.textColor = UIColor.darkGray
            contentView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1)
            contentView.layer.borderColor = UIColor.gray.cgColor
        }

        imageView.image = image
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(
                    withDuration: 0.15,
                    delay: 0,
                    options: [.allowUserInteraction],
                    animations: {
                        self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        self.layer.shadowOpacity = 0.4
                        self.layer.shadowRadius = 10
                    }
                )
            } else {
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 3,
                    options: [.allowUserInteraction],
                    animations: {
                        self.contentView.transform = .identity
                        self.layer.shadowOpacity = 0.2
                        self.layer.shadowRadius = 6
                    }
                )
            }
        }
    }
}
