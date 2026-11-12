import UIKit

final class SalesListViewController: UITableViewController, UISearchResultsUpdating {
    private let user: Usuario
    private let supervisorMode: Bool
    private let search = UISearchController(searchResultsController: nil)
    private let periodControl = UISegmentedControl(items: ["Todas", "Hoy", "Mes"])
    private var selectedPeriod: SalesPeriod = .all
    private var selectedSeller: Usuario?
    private var allSales: [Venta] = []
    private var visibleSales: [Venta] = []
    private var query = ""

    init(user: Usuario, supervisorMode: Bool) {
        self.user = user
        self.supervisorMode = supervisorMode
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no está implementado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppStyle.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SaleCell")
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Buscar cliente o producto"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false

        periodControl.selectedSegmentIndex = 0
        periodControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 58))
        periodControl.frame = header.bounds.insetBy(dx: 14, dy: 8)
        header.addSubview(periodControl)
        tableView.tableHeaderView = header

        if supervisorMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Vendedores", style: .plain, target: self, action: #selector(chooseSeller))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSales()
    }

    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text ?? ""
        applySearch()
    }

    @objc private func periodChanged() {
        selectedPeriod = SalesPeriod(rawValue: periodControl.selectedSegmentIndex) ?? .all
        loadSales()
    }

    private func loadSales() {
        do {
            allSales = try SalesService.shared.sales(isSupervisor: supervisorMode, viewer: user, period: selectedPeriod, seller: selectedSeller)
            applySearch()
        } catch { showError(error) }
    }

    private func applySearch() {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        visibleSales = allSales.filter { sale in
            needle.isEmpty || (sale.cliente?.nombre.localizedCaseInsensitiveContains(needle) ?? false) ||
            (sale.producto?.nombre.localizedCaseInsensitiveContains(needle) ?? false) ||
            (sale.vendedor?.nombre.localizedCaseInsensitiveContains(needle) ?? false)
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visibleSales.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaleCell", for: indexPath)
        let sale = visibleSales[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(sale.cliente?.nombre ?? "Cliente") · \(AppStyle.money(sale.total))"
        var detail = "\(sale.producto?.nombre ?? "Producto") × \(sale.cantidad) · \(sale.fecha.shortDateAndTime)"
        if supervisorMode { detail += " · \(sale.vendedor?.nombre ?? "Vendedor")" }
        if sale.anulada { detail += " · ANULADA: \(sale.motivoAnulacion ?? "")" }
        content.secondaryText = detail
        content.secondaryTextProperties.color = sale.anulada ? .systemRed : AppStyle.muted
        content.image = UIImage(systemName: sale.anulada ? "xmark.circle.fill" : "receipt.fill")
        content.imageProperties.tintColor = sale.anulada ? .systemRed : AppStyle.teal
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard supervisorMode else { return nil }
        let sale = visibleSales[indexPath.row]
        guard !sale.anulada else { return nil }
        let annul = UIContextualAction(style: .destructive, title: "Anular") { [weak self] _, _, done in
            guard let self else { done(false); return }
            self.navigationController?.pushViewController(AnnulSaleViewController(user: self.user, sale: sale), animated: true)
            done(true)
        }
        annul.image = UIImage(systemName: "xmark.circle")
        return UISwipeActionsConfiguration(actions: [annul])
    }

    @objc private func chooseSeller() {
        do {
            let sellers = try SalesService.shared.sellers()
            let alert = UIAlertController(title: "Filtrar por vendedor", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Todos", style: .default) { [weak self] _ in self?.selectedSeller = nil; self?.loadSales() })
            for seller in sellers {
                alert.addAction(UIAlertAction(title: seller.nombre, style: .default) { [weak self] _ in self?.selectedSeller = seller; self?.loadSales() })
            }
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            if let popover = alert.popoverPresentationController { popover.barButtonItem = navigationItem.rightBarButtonItem }
            present(alert, animated: true)
        } catch { showError(error) }
    }
}
