import UIKit

final class AccountViewController: UIViewController {
    private let user: Usuario

    init(user: Usuario) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no está implementado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cuenta"
        view.backgroundColor = AppStyle.background

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48)
        ])

        let avatar = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        avatar.tintColor = AppStyle.teal
        avatar.contentMode = .scaleAspectFit
        avatar.heightAnchor.constraint(equalToConstant: 76).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: 76).isActive = true
        let name = UILabel()
        name.text = user.nombre
        name.font = .systemFont(ofSize: 24, weight: .bold)
        name.textColor = AppStyle.navy
        let username = UILabel()
        username.text = "@\(user.usuario)"
        username.textColor = AppStyle.muted
        let role = UILabel()
        role.text = user.rol
        role.textColor = AppStyle.teal
        role.font = .systemFont(ofSize: 15, weight: .semibold)
        role.backgroundColor = AppStyle.teal.withAlphaComponent(0.1)
        role.textAlignment = .center
        role.layer.cornerRadius = 10
        role.clipsToBounds = true
        role.heightAnchor.constraint(equalToConstant: 34).isActive = true
        role.widthAnchor.constraint(greaterThanOrEqualToConstant: 110).isActive = true

        let note = UILabel()
        note.text = "El menú y las acciones disponibles dependen de tu rol."
        note.textColor = AppStyle.muted
        note.textAlignment = .center
        note.numberOfLines = 0
        let logout = AppStyle.button("Cerrar sesión", color: AppStyle.navy)
        logout.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        [avatar, name, username, role, note, logout].forEach(stack.addArrangedSubview)
        logout.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    @objc private func logoutTapped() {
        (UIApplication.shared.delegate as? AppDelegate)?.showLogin()
    }
}
