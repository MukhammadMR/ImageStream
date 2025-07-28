import Foundation
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let avatarImageView = UIImageView()
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileObserver: NSObjectProtocol?

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = profileObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.updateAvatar()
            })

        profileObserver = NotificationCenter.default.addObserver(
            forName: ProfileService.profileDidUpdateNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.updateProfileUI()
            })

        updateAvatar()
        updateProfileUI()
    }

    private func updateAvatar() {
        guard let avatarURLString = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarURLString) else { return }
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(resource: .avatar))
    }

    private func updateProfileUI() {
        guard let profile = ProfileService.shared.profile else {
            print("Profile is nil")
            return
        }
        print("Updating profile UI with data:")
        print("Name:", profile.name)
        print("Login:", profile.loginName)
        print("Bio:", profile.bio ?? "nil")
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? ""
    }


    @IBAction private func didTapLogoutButton(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        present(alert, animated: true)
    }

    private func setupUI() {
        let logoutButton = UIButton(type: .system)

        view.backgroundColor = UIColor(named: "YPBackground") ?? UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)

        configureAvatarImageView(avatarImageView)
        configureNameLabel(nameLabel)
        configureLoginNameLabel(loginNameLabel)
        configureDescriptionLabel(descriptionLabel)
        configureLogoutButton(logoutButton)

        addSubviews([avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton])
        setupConstraints(avatarImageView: avatarImageView,
                         nameLabel: nameLabel,
                         loginNameLabel: loginNameLabel,
                         descriptionLabel: descriptionLabel,
                         logoutButton: logoutButton)
    }

    private func configureAvatarImageView(_ imageView: UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Avatar")
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
    }

    private func configureNameLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor(named: "YP White") ?? .white
    }

    private func configureLoginNameLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Gray (iOS)") ?? UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    }

    private func configureDescriptionLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP White") ?? .white
    }

    private func configureLogoutButton(_ button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoutImage = UIImage(named: "logout_button")?.withRenderingMode(.alwaysOriginal)
        button.setImage(logoutImage, for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

    private func addSubviews(_ views: [UIView]) {
        views.forEach { view.addSubview($0) }
    }

    private func setupConstraints(avatarImageView: UIImageView,
                                  nameLabel: UILabel,
                                  loginNameLabel: UILabel,
                                  descriptionLabel: UILabel,
                                  logoutButton: UIButton) {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
