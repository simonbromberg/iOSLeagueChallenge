//
//  PostsViewController.swift
//  LeagueiOSChallenge
//
//  Created by Simon Bromberg on 2025-02-11.
//

import UIKit
import SwiftUI

class PostsViewController: UIViewController, UITableViewDelegate {
  private let viewModel: PostsViewModel

  init(apiService: APIService = APIHelper()) {
    self.viewModel = PostsViewModel(apiService: apiService)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private typealias DataSource = UITableViewDiffableDataSource<Section, UserPost>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UserPost>

  private lazy var dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostTableViewCell

    cell.titleLabel.text = item.title
    cell.descriptionLabel.text = item.description
    cell.usernameLabel.text = item.username

    cell.avatarImageView.image = self.loadImage(item.avatar, indexPath: indexPath)

    if cell.userTappableView?.gestureRecognizers?.isEmpty != false {
      let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedUser(_:)))
      cell.userTappableView?.addGestureRecognizer(tapRecognizer)
    }

    return cell
  }

  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.backgroundColor = .background

    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Posts"

    navigationItem.rightBarButtonItem = .init(
      title: viewModel.logOutButtonTitle,
      style: .done,
      target: self,
      action: #selector(logOut)
    )

    tableView.delegate = self
    tableView.dataSource = dataSource

    view.addSubview(tableView)

    tableView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
    tableView.refreshControl = refreshControl

    loadPosts()
  }

  func applySnapshot(animatingDifferences: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(viewModel.userPosts)
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }

  @objc private func loadPosts() {
    Task {
      do {
        try await viewModel.fetchPosts()
      } catch {
        print(error)
      }
      applySnapshot()
      tableView.refreshControl?.endRefreshing()

      if viewModel.userPosts.isEmpty {
        tableView.tableFooterView = NoDataView()
      } else {
        tableView.tableFooterView = nil
      }
    }
  }

  private func loadImage(_ url: String?, indexPath: IndexPath) -> UIImage {
    let image = viewModel.getImage(url, index: indexPath.row) {
      DispatchQueue.main.async { [weak self] in
        self?.applySnapshot()
      }
    }
    return image
  }

  @objc private func tappedUser(_ sender: UITapGestureRecognizer) {
    guard let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)) else { return }
    present(viewModel.userViewController(forTappedIndexPath: indexPath), animated: true)
  }

  @objc private func logOut() {
    let logOutAction = viewModel.logOut()

    switch logOutAction {
    case .goToLogin:
      dismiss(animated: true)
    case .thankForTrialing:
      let alert = UIAlertController(title: "Thank you for trialing this app", message: nil, preferredStyle: .alert)
      alert.addAction(.init(title: "OK", style: .default) { [unowned self] _ in
        self.dismiss(animated: true)
      })
      present(alert, animated: true)
    }
  }

  private enum Section {
    case main
  }
}

private class NoDataView: UIView {
  init() {
    super.init(frame: .zero)
    let label = UILabel()
    label.text = "No posts found!"
    label.textColor = .secondaryText

    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])  
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
