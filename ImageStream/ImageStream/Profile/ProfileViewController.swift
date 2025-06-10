import UIKit

final class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func didTapLogoutButton() {
        // TODO: logout action
    }

    private func setupUI() {
        let avatarImageView = UIImageView()
        let nameLabel = UILabel()
        let loginNameLabel = UILabel()
        let descriptionLabel = UILabel()
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
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor(named: "YP White") ?? .white
    }

    private func configureLoginNameLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Gray (iOS)") ?? UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    }

    private func configureDescriptionLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
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
