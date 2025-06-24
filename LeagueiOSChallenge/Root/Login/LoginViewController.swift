//
//  LoginViewController.swift
//  LeagueiOSChallenge
//
//  Copyright © 2024 League Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  private let apiService: APIService

  init(apiService: APIService = APIHelper()) {
    self.apiService = apiService
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let usernameField = UITextField(placeholder: "Username", textContentType: .username)
  private let passwordField = UITextField(placeholder: "Password", textContentType: .password)

  private let loginButton = UIButton(title: "Login")
  private let continueAsGuestButton = UIButton(title: "Continue as guest")

  private let loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.hidesWhenStopped = true
    return indicator
  }()

  private var keyboardObservers = [NSObjectProtocol]()

  private var stackViewBottomConstraint: NSLayoutConstraint?

  override func viewDidLoad() {
    super.viewDidLoad()

    let placeholderLogo = UIImage(systemName: "figure.socialdance.circle.fill")
    let imageView = UIImageView(image: placeholderLogo)
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .primaryText

    loginButton.addTarget(self, action: #selector(logIn), for: .touchUpInside)
    continueAsGuestButton.addTarget(self, action: #selector(continueAsGuest), for: .touchUpInside)

    let stackView = UIStackView(
      arrangedSubviews: [
        imageView,
        usernameField,
        passwordField,
        .spacer(),
        loadingIndicator,
        loginButton,
        continueAsGuestButton,
        .spacer(),
      ]
    )
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 20

    [stackView, imageView, loginButton, continueAsGuestButton, stackView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    view.addSubview(stackView)

    stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 60),
      loginButton.heightAnchor.constraint(equalToConstant: 40),
      continueAsGuestButton.heightAnchor.constraint(equalToConstant: 40),
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      stackViewBottomConstraint!,
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
    ])

    view.backgroundColor = .background

    let tapRecognizer = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
    view.addGestureRecognizer(tapRecognizer)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if apiService.currentLoginState() != nil {
      continueToPosts()
    } else {
      observeKeyboardNotifications()
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    keyboardObservers.forEach {
      NotificationCenter.default.removeObserver($0)
    }
  }

  private func observeKeyboardNotifications() {
    keyboardObservers = [
      NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
        guard let keyboardHeight = notification.keyboardHeight,
              self?.stackViewBottomConstraint?.constant == 0
        else {
          return
        }

        self?.stackViewBottomConstraint?.constant = -keyboardHeight
        self?.view.updateLayoutAnimated()
      },
      NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
        if self?.stackViewBottomConstraint?.constant != 0 {
          self?.stackViewBottomConstraint?.constant = 0
          self?.view.updateLayoutAnimated()
        }
      }
    ]
  }

  private var isLoading: Bool = false {
    didSet {
      isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
      loginButton.isEnabled = !isLoading
      continueAsGuestButton.isEnabled = !isLoading
    }
  }

  @objc private func logIn() {
    guard let username = usernameField.text,
          let password = passwordField.text,
          !username.isEmpty,
          !password.isEmpty
    else { return }

    isLoading = true

    Task {
      do {
        try await apiService.logIn(username: username, password: password)

        usernameField.text = nil
        passwordField.text = nil

        continueToPosts()
      } catch {
        print("Log in error: \(error)")
      }
      isLoading = false
    }
  }

  @objc private func continueAsGuest() {
    isLoading = true
    Task {
      do {
        try await apiService.logInAsGuest()
        continueToPosts()
      } catch {
        print("Cotinue as guest error: \(error)")
      }
      isLoading = false
    }
  }

  func continueToPosts() {
    let navigationController = UINavigationController(rootViewController: PostsViewController(apiService: apiService))
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: true)
  }
}

private extension UIView {
  static func spacer(height: CGFloat = .greatestFiniteMagnitude) -> UIView {
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    let constraint = spacer.heightAnchor.constraint(equalToConstant: height)
    constraint.priority = .defaultLow
    constraint.isActive = true
    return spacer
  }
}

private extension UIButton {
  convenience init(title: String) {
    self.init(type: .system)
    setTitle(title, for: .normal)
    setTitleColor(.primaryText, for: .normal)
    titleLabel?.textAlignment = .center
    layer.cornerRadius = 8
    layer.borderWidth = 1
    layer.borderColor = UIColor.border.cgColor
  }
}

private extension UITextField {
  convenience init(placeholder: String, textContentType: UITextContentType) {
    self.init()
    attributedPlaceholder = .init(string: placeholder, attributes: [.foregroundColor: UIColor.placeholderText])
    textColor = .primaryText
    autocapitalizationType = .none
    autocorrectionType = .no
    self.textContentType = textContentType
    if textContentType == .password {
      isSecureTextEntry = true
    }
  }
}

private extension Notification {
  var keyboardHeight: CGFloat? {
    (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
  }
}

private extension UIView {
  func updateLayoutAnimated() {
    UIView.animate(withDuration: 1) {
      self.layoutIfNeeded()
    }
  }
}
