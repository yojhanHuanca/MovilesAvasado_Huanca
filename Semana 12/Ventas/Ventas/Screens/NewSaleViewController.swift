import UIKit

final class NewSaleViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    private let user: Usuario
    private let picker = UIPickerView()
    private let quantityStepper = UIStepper()
    private let quantityLabel = UILabel()
    private let subtotalLabel = UILabel()
    private let discountLabel = UILabel()
    private let taxLabel = UILabel()
    private let totalLabel = UILabel()
    private let clientHint = UILabel()
    private var clients: [Cliente] = []
    private var products: [Producto] = []
    private var quantity = 1

    private var selectedClient: Cliente? { clients.indices.contains(picker.selectedRow(inComponent: 0)) ? clients[picker.selectedRow(inComponent: 0)] : nil }
    private var selectedProduct: Producto? { products.indices.contains(picker.selectedRow(inComponent: 1)) ? products[picker.selectedRow(inComponent: 1)] : nil }

    init(user: Usuario) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no está implementado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nueva venta"
        view.backgroundColor = AppStyle.background
        picker.dataSource = self
        picker.delegate = self
        quantityStepper.minimumValue = 1
        quantityStepper.addTarget(self, action: #selector(quantityChanged), for: .valueChanged)
        buildScreen()
        loadData()
    }

    private func buildScreen() {
        let stack = makeStack(spacing: 14)
        let intro = UILabel()
        intro.text = "Selecciona un cliente y un producto. El total se actualiza automáticamente."
        intro.textColor = AppStyle.muted
        intro.numberOfLines = 0
        let sectionTitle = UILabel()
        sectionTitle.text = "CLIENTE Y PRODUCTO"
        sectionTitle.font = .systemFont(ofSize: 12, weight: .bold)
        sectionTitle.textColor = AppStyle.muted
        picker.heightAnchor.constraint(equalToConstant: 176).isActive = true

        clientHint.textColor = AppStyle.teal
        clientHint.font = .systemFont(ofSize: 13, weight: .medium)
        clientHint.textAlignment = .center

        let quantityRow = UIStackView(arrangedSubviews: [quantityLabel, UIView(), quantityStepper])
        quantityRow.axis = .horizontal
        quantityRow.alignment = .center
        quantityLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        let summary = makeStack(spacing: 8)
        summary.layoutMargins = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 16)
        summary.isLayoutMarginsRelativeArrangement = true
        summary.backgroundColor = .secondarySystemBackground
        summary.layer.cornerRadius = 14
        addSummaryRow("Subtotal", label: subtotalLabel, to: summary)
        addSummaryRow("Descuento", label: discountLabel, to: summary)
        addSummaryRow("IGV (18 %)", label: taxLabel, to: summary)
        addSummaryRow("Total", label: totalLabel, to: summary, emphasize: true)

        let saleButton = AppStyle.button("Registrar venta")
        saleButton.addTarget(self, action: #selector(registerSale), for: .touchUpInside)

        [intro, sectionTitle, picker, clientHint, quantityRow, summary, saleButton].forEach(stack.addArrangedSubview)
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.addSubview(stack)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -18),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -36)
        ])
    }

    private func addSummaryRow(_ title: String, label: UILabel, to stack: UIStackView, emphasize: Bool = false) {
        let caption = UILabel()
        caption.text = title
        caption.textColor = emphasize ? AppStyle.navy : AppStyle.muted
        label.textAlignment = .right
        label.textColor = emphasize ? AppStyle.teal : AppStyle.navy
        label.font = .systemFont(ofSize: emphasize ? 18 : 15, weight: emphasize ? .bold : .regular)
        let row = UIStackView(arrangedSubviews: [caption, label])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        stack.addArrangedSubview(row)
    }

    private func loadData() {
        do {
            clients = try SalesService.shared.clients()
            products = try SalesService.shared.products()
            picker.reloadAllComponents()
            updateSummary()
        } catch { showError(error) }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { component == 0 ? clients.count : products.count }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            guard clients.indices.contains(row) else { return "Sin clientes" }
            return clients[row].nombre
        }
        guard products.indices.contains(row) else { return "Sin productos" }
        let product = products[row]
        return "\(product.nombre) · stock \(product.stock)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        quantity = 1
        updateSummary()
    }

    @objc private func quantityChanged() {
        quantity = Int(quantityStepper.value)
        updateSummary()
    }

    private func updateSummary() {
        let stock = Int(selectedProduct?.stock ?? 0)
        quantityStepper.maximumValue = Double(max(stock, 1))
        if quantity > max(stock, 1) { quantity = max(stock, 1); quantityStepper.value = Double(quantity) }
        quantityLabel.text = "Cantidad: \(quantity)"
        if let client = selectedClient, let product = selectedProduct {
            let category = SalesService.shared.category(for: client)
            clientHint.text = "\(category) · descuento VIP del 10 %"
            let amounts = SalesService.shared.calculateSale(client: client, product: product, quantity: quantity)
            subtotalLabel.text = AppStyle.money(amounts.subtotal)
            discountLabel.text = "− \(AppStyle.money(amounts.discount))"
            taxLabel.text = AppStyle.money(amounts.tax)
            totalLabel.text = AppStyle.money(amounts.total)
        } else {
            clientHint.text = "Agrega clientes y productos antes de registrar una venta."
            [subtotalLabel, discountLabel, taxLabel, totalLabel].forEach { $0.text = AppStyle.money(0) }
        }
        quantityStepper.isEnabled = stock > 0
    }

    @objc private func registerSale() {
        guard let client = selectedClient, let product = selectedProduct else {
            showMessage("Faltan datos", message: "Primero debe existir al menos un cliente y un producto.")
            return
        }
        do {
            let sale = try SalesService.shared.createSale(seller: user, client: client, product: product, quantity: quantity)
            showMessage("Venta registrada", message: "Total: \(AppStyle.money(sale.total)) · Stock actualizado.")
            loadData()
        } catch { showError(error) }
    }
}
