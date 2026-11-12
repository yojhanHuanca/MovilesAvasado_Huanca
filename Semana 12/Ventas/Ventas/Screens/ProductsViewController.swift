import UIKit

final class ProductsViewController: UITableViewController, UISearchResultsUpdating {
    private let user: Usuario
    private let search = UISearchController(searchResultsController: nil)
    private let categoryControl = UISegmentedControl(items: ["Todos", "Tecnología", "Accesorios"])
    private var allProducts: [Producto] = []
    private var visibleProducts: [Producto] = []
    private var query = ""

    private var isSupervisor: Bool { user.rol == AppRole.supervisor }

    init(user: Usuario) {
        self.user = user
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no está implementado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppStyle.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Buscar producto"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        categoryControl.selectedSegmentIndex = 0
        categoryControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 58))
        categoryControl.frame = header.bounds.insetBy(dx: 16, dy: 8)
        header.addSubview(categoryControl)
        tableView.tableHeaderView = header
        if isSupervisor {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProduct))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }

    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text ?? ""
        applyFilters()
    }

    @objc private func categoryChanged() { applyFilters() }

    private func loadProducts() {
        do { allProducts = try SalesService.shared.products(); applyFilters() }
        catch { showError(error) }
    }

    private func applyFilters() {
        let category = categoryControl.selectedSegmentIndex == 1 ? "Tecnología" : (categoryControl.selectedSegmentIndex == 2 ? "Accesorios" : nil)
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        visibleProducts = allProducts.filter { product in
            (category == nil || product.categoria == category!) &&
            (needle.isEmpty || product.nombre.localizedCaseInsensitiveContains(needle) || product.categoria.localizedCaseInsensitiveContains(needle))
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visibleProducts.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = visibleProducts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = product.nombre
        let status = product.stock <= 5 ? "Stock bajo" : "Disponible"
        content.secondaryText = "\(product.categoria) · \(AppStyle.money(product.precio)) · \(product.stock) unidades · \(status)"
        content.secondaryTextProperties.color = product.stock <= 5 ? .systemOrange : AppStyle.muted
        content.image = UIImage(systemName: "shippingbox.fill")
        content.imageProperties.tintColor = AppStyle.teal
        cell.contentConfiguration = content
        cell.accessoryType = isSupervisor ? .disclosureIndicator : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard isSupervisor else { return }
        editProduct(visibleProducts[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isSupervisor else { return nil }
        let product = visibleProducts[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, done in
            do { try SalesService.shared.deleteProduct(product); self?.loadProducts(); done(true) }
            catch { self?.showError(error); done(false) }
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    @objc private func addProduct() { presentProductForm(product: nil) }
    private func editProduct(_ product: Producto) { presentProductForm(product: product) }

    private func presentProductForm(product: Producto?) {
        let alert = UIAlertController(title: product == nil ? "Nuevo producto" : "Editar producto", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Nombre"; $0.text = product?.nombre }
        alert.addTextField { $0.placeholder = "Categoría"; $0.text = product?.categoria ?? "Tecnología" }
        alert.addTextField { $0.placeholder = "Precio"; $0.keyboardType = .decimalPad; $0.text = product.map { String($0.precio) } }
        alert.addTextField { $0.placeholder = "Stock"; $0.keyboardType = .numberPad; $0.text = product.map { String($0.stock) } }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            let fields = alert.textFields ?? []
            let priceText = (fields.count > 2 ? fields[2].text : "")?.replacingOccurrences(of: ",", with: ".") ?? ""
            do {
                guard let price = Double(priceText), let stock = Int(fields.count > 3 ? fields[3].text ?? "" : "") else { throw BusinessError.missingData }
                try SalesService.shared.saveProduct(existing: product, name: fields.first?.text ?? "", category: fields.count > 1 ? fields[1].text ?? "" : "", price: price, stock: stock)
                self?.loadProducts()
            } catch { self?.showError(error) }
        })
        present(alert, animated: true)
    }
}
