import UIKit

final class LoginViewController: UIViewController {
    private let usernameField = AppStyle.field("Usuario")
    private let passwordField = AppStyle.field("Clave", secure: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ventas"
        view.backgroundColor = AppStyle.background
        buildScreen()
    }

    private func buildScreen() {
        let scroll = UIScrollView()
        let content = makeStack(spacing: 18)
        let mark = UIImageView(image: UIImage(systemName: "storefront.fill"))
        mark.tintColor = AppStyle.teal
        mark.contentMode = .scaleAspectFit
        mark.heightAnchor.constraint(equalToConstant: 76).isActive = true

        let heading = UILabel()
        heading.text = "Ventas"
        heading.textColor = AppStyle.navy
        heading.font = .systemFont(ofSize: 30, weight: .bold)
        heading.textAlignment = .center

        let subtitle = UILabel()
        subtitle.text = "Ingresa para continuar"
        subtitle.textColor = AppStyle.muted
        subtitle.textAlignment = .center

        let loginButton = AppStyle.button("Ingresar")
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Crear cuenta", for: .normal)
        registerButton.setTitleColor(AppStyle.teal, for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        let demoNote = UILabel()
        demoNote.text = "Cuenta de demostración: demo / demo123"
        demoNote.textColor = AppStyle.muted
        demoNote.font = .systemFont(ofSize: 13)
        demoNote.textAlignment = .center

        content.addArrangedSubview(mark)
        content.addArrangedSubview(heading)
        content.addArrangedSubview(subtitle)
        content.addArrangedSubview(usernameField)
        content.addArrangedSubview(passwordField)
        content.addArrangedSubview(loginButton)
        content.addArrangedSubview(registerButton)
        content.addArrangedSubview(demoNote)

        view.addSubview(scroll)
        scroll.addSubview(content)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 28),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -28),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 44),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -28),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -56)
        ])
    }

    @objc private func loginTapped() {
        do {
            let user = try SalesService.shared.login(
                username: usernameField.text ?? "",
                password: passwordField.text ?? ""
            )
            (UIApplication.shared.delegate as? AppDelegate)?.showMain(for: user)
        } catch {
            showError(error)
        }
    }

    @objc private func registerTapped() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
}

final class RegisterViewController: UIViewController {
    private let nameField = AppStyle.field("Nombre completo")
    private let usernameField = AppStyle.field("Usuario")
    private let passwordField = AppStyle.field("Clave (mínimo 6 caracteres)", secure: true)
    private let confirmationField = AppStyle.field("Confirmar clave", secure: true)
    private let roleControl = UISegmentedControl(items: [AppRole.seller, AppRole.supervisor])

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Crear cuenta"
        view.backgroundColor = AppStyle.background
        buildScreen()
    }

    private func buildScreen() {
        let content = makeStack(spacing: 16)
        let description = UILabel()
        description.text = "Registra tus datos y elige el rol para esta práctica."
        description.textColor = AppStyle.muted
        description.numberOfLines = 0
        roleControl.selectedSegmentIndex = 0

        let saveButton = AppStyle.button("Registrarme")
        saveButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        [nameField, usernameField, passwordField, confirmationField].forEach {
            $0.autocapitalizationType = .none
        }
        content.addArrangedSubview(description)
        content.addArrangedSubview(nameField)
        content.addArrangedSubview(usernameField)
        content.addArrangedSubview(passwordField)
        content.addArrangedSubview(confirmationField)
        content.addArrangedSubview(roleControl)
        content.addArrangedSubview(saveButton)

        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.addSubview(content)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 22),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -22),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -44)
        ])
    }

    @objc private func registerTapped() {
        do {
            let role = roleControl.selectedSegmentIndex == 0 ? AppRole.seller : AppRole.supervisor
            let user = try SalesService.shared.registerUser(
                name: nameField.text ?? "",
                username: usernameField.text ?? "",
                password: passwordField.text ?? "",
                confirmation: confirmationField.text ?? "",
                role: role
            )
            (UIApplication.shared.delegate as? AppDelegate)?.showMain(for: user)
        } catch {
            showError(error)
        }
    }
}
