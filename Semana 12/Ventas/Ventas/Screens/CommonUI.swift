import UIKit

enum AppStyle {
    static let navy = UIColor(red: 0.09, green: 0.18, blue: 0.29, alpha: 1)
    static let teal = UIColor(red: 0.05, green: 0.48, blue: 0.43, alpha: 1)
    static let gold = UIColor(red: 0.94, green: 0.63, blue: 0.04, alpha: 1)
    static let background = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
    static let muted = UIColor.secondaryLabel

    static func field(_ placeholder: String, secure: Bool = false) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.isSecureTextEntry = secure
        field.backgroundColor = .secondarySystemBackground
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return field
    }

    static func button(_ title: String, color: UIColor = teal) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }

    static func money(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.numberStyle = .currency
        formatter.currencyCode = "PEN"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "S/ %.2f", value)
    }
}

extension UIViewController {
    func showMessage(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }

    func showError(_ error: Error) {
        showMessage("Revisa los datos", message: error.localizedDescription)
    }

    func makeStack(spacing: CGFloat = 14) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    func pin(_ view: UIView, inside parent: UIView, inset: CGFloat = 20) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset),
            view.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset)
        ])
    }
}

extension Date {
    var shortDateAndTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var weekdayInitial: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateFormat = "EE"
        return formatter.string(from: self).capitalized
    }
}
