//
//  PostTableViewCell.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-11.
//

import UIKit

class PostTableViewCell: UITableViewCell {
  let avatarImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .init(systemName: "person.fill")
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .placeholderText

    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 25

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

    return imageView
  }()

  let usernameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryText
    label.font = .boldSystemFont(ofSize: 15)
    label.accessibilityIdentifier = "postUsernameLabel"
    return label
  }()

  let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryText
    label.font = .italicSystemFont(ofSize: 14)
    return label
  }()

  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.textColor = .placeholderText
    label.font = .systemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    selectionStyle = .none

    setUpViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var userTappableView: UIView?

  private func setUpViews() {
    let userStackView = UIStackView(arrangedSubviews: [avatarImageView, usernameLabel])
    userStackView.axis = .horizontal
    userStackView.distribution = .fillProportionally
    userStackView.spacing = 4

    userTappableView = userStackView
    userTappableView?.isUserInteractionEnabled = true

    let stackView = UIStackView(arrangedSubviews: [userStackView, titleLabel, descriptionLabel])
    stackView.axis = .vertical
    stackView.spacing = 8

    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false

    let margin: CGFloat = 10
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),
    ])
  }
}
