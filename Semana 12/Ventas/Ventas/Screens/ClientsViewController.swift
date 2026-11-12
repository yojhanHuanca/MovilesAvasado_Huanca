import UIKit

final class ClientsViewController: UITableViewController, UISearchResultsUpdating {
    private let user: Usuario
    private let search = UISearchController(searchResultsController: nil)
    private var allClients: [Cliente] = []
    private var visibleClients: [Cliente] = []
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ClientCell")
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Buscar cliente"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addClient))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadClients()
    }

    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text ?? ""
        applyFilter()
    }

    private func loadClients() {
        do { allClients = try SalesService.shared.clients(); applyFilter() }
        catch { showError(error) }
    }

    private func applyFilter() {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        visibleClients = allClients.filter {
            needle.isEmpty || $0.nombre.localizedCaseInsensitiveContains(needle) || $0.documento.localizedCaseInsensitiveContains(needle)
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visibleClients.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)
        let client = visibleClients[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = client.nombre
        content.secondaryText = "\(client.documento) · \(SalesService.shared.category(for: client)) · Compras: \(AppStyle.money(SalesService.shared.amountSpent(by: client)))"
        content.image = UIImage(systemName: "person.crop.circle.fill")
        content.imageProperties.tintColor = SalesService.shared.category(for: client) == "VIP" ? AppStyle.gold : AppStyle.teal
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentClientForm(client: visibleClients[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isSupervisor else { return nil }
        let client = visibleClients[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, done in
            do { try SalesService.shared.deleteClient(client); self?.loadClients(); done(true) }
            catch { self?.showError(error); done(false) }
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    @objc private func addClient() { presentClientForm(client: nil) }

    private func presentClientForm(client: Cliente?) {
        let alert = UIAlertController(title: client == nil ? "Nuevo cliente" : "Editar cliente", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Nombre completo"; $0.text = client?.nombre; $0.autocapitalizationType = .words }
        alert.addTextField { $0.placeholder = "DNI o documento"; $0.text = client?.documento; $0.keyboardType = .numberPad }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            do {
                let fields = alert.textFields ?? []
                try SalesService.shared.saveClient(existing: client, name: fields.first?.text ?? "", document: fields.count > 1 ? fields[1].text ?? "" : "")
                self?.loadClients()
            } catch { self?.showError(error) }
        })
        present(alert, animated: true)
    }
}
