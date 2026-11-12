import UIKit

final class AnnulSaleViewController: UIViewController {
    private let user: Usuario
    private let sale: Venta
    private let reasonView = UITextView()

    init(user: Usuario, sale: Venta) {
        self.user = user
        self.sale = sale
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no está implementado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Anular venta"
        view.backgroundColor = AppStyle.background

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.addSubview(stack)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        let heading = UILabel()
        heading.text = "Confirma la anulación"
        heading.font = .systemFont(ofSize: 23, weight: .bold)
        heading.textColor = AppStyle.navy

        let details = UIStackView()
        details.axis = .vertical
        details.spacing = 8
        details.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        details.isLayoutMarginsRelativeArrangement = true
        details.backgroundColor = .secondarySystemBackground
        details.layer.cornerRadius = 14
        [
            "Cliente: \(sale.cliente?.nombre ?? "—")",
            "Producto: \(sale.producto?.nombre ?? "—") × \(sale.cantidad)",
            "Fecha: \(sale.fecha.shortDateAndTime)",
            "Total: \(AppStyle.money(sale.total))",
            "Vendedor: \(sale.vendedor?.nombre ?? "—")"
        ].forEach { line in
            let label = UILabel()
            label.text = line
            label.textColor = AppStyle.navy
            label.font = .systemFont(ofSize: 15)
            details.addArrangedSubview(label)
        }

        let prompt = UILabel()
        prompt.text = "Motivo de anulación (obligatorio)"
        prompt.font = .systemFont(ofSize: 15, weight: .semibold)
        prompt.textColor = AppStyle.navy
        reasonView.font = .systemFont(ofSize: 16)
        reasonView.backgroundColor = .secondarySystemBackground
        reasonView.layer.cornerRadius = 12
        reasonView.layer.borderWidth = 1
        reasonView.layer.borderColor = UIColor.separator.cgColor
        reasonView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        reasonView.heightAnchor.constraint(equalToConstant: 126).isActive = true
        reasonView.accessibilityLabel = "Motivo de anulación obligatorio"

        let note = UILabel()
        note.text = "Al confirmar, las unidades vuelven al stock y la venta deja de contar en los reportes y en la categoría del cliente."
        note.textColor = AppStyle.muted
        note.font = .systemFont(ofSize: 13)
        note.numberOfLines = 0

        let confirm = AppStyle.button("Confirmar anulación", color: .systemRed)
        confirm.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        let cancel = UIButton(type: .system)
        cancel.setTitle("Cancelar", for: .normal)
        cancel.setTitleColor(AppStyle.teal, for: .normal)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        [heading, details, prompt, reasonView, note, confirm, cancel].forEach(stack.addArrangedSubview)
    }

    @objc private func confirmTapped() {
        do {
            try SalesService.shared.annul(sale: sale, supervisor: user, reason: reasonView.text ?? "")
            let alert = UIAlertController(title: "Venta anulada", message: "Se devolvieron \(sale.cantidad) unidades al inventario.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continuar", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } catch { showError(error) }
    }

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
}
