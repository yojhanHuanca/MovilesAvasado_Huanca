import UIKit

final class DashboardViewController: UIViewController {
    private let user: Usuario
    private let content = UIStackView()

    init(user: Usuario) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no está implementado") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resumen"
        view.backgroundColor = AppStyle.background
        content.axis = .vertical
        content.spacing = 18
        content.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.addSubview(content)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -18),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 18),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -36)
        ])
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    private func refresh() {
        content.arrangedSubviews.forEach { content.removeArrangedSubview($0); $0.removeFromSuperview() }
        do {
            let sales = try SalesService.shared.sales(isSupervisor: true, viewer: user, period: .all)
            let validSales = sales.filter { !$0.anulada }
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            let monthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? today
            let todaySales = validSales.filter { $0.fecha >= today && $0.fecha < (calendar.date(byAdding: .day, value: 1, to: today) ?? today) }
            let yesterdaySales = validSales.filter { $0.fecha >= yesterday && $0.fecha < today }
            let monthSales = validSales.filter { $0.fecha >= monthStart }

            let heading = UILabel()
            heading.text = "Hola, \(user.nombre)"
            heading.textColor = AppStyle.navy
            heading.font = .systemFont(ofSize: 24, weight: .bold)
            let caption = UILabel()
            caption.text = "Resumen de ventas y stock"
            caption.textColor = AppStyle.muted

            let firstMetrics = UIStackView(arrangedSubviews: [metricCard("Hoy", value: AppStyle.money(todaySales.reduce(0) { $0 + $1.total }), icon: "sun.max.fill"), metricCard("Ayer", value: AppStyle.money(yesterdaySales.reduce(0) { $0 + $1.total }), icon: "clock.arrow.circlepath")])
            firstMetrics.axis = .horizontal
            firstMetrics.spacing = 12
            firstMetrics.distribution = .fillEqually
            let secondMetrics = UIStackView(arrangedSubviews: [metricCard("Este mes", value: AppStyle.money(monthSales.reduce(0) { $0 + $1.total }), icon: "calendar"), metricCard("Ventas del mes", value: "\(monthSales.count)", icon: "receipt")])
            secondMetrics.axis = .horizontal
            secondMetrics.spacing = 12
            secondMetrics.distribution = .fillEqually

            content.addArrangedSubview(heading)
            content.addArrangedSubview(caption)
            content.addArrangedSubview(firstMetrics)
            content.addArrangedSubview(secondMetrics)
            content.addArrangedSubview(sectionLabel("Últimos 7 días"))
            content.addArrangedSubview(weekChart(validSales))
            content.addArrangedSubview(sectionLabel("Vendedores del mes"))
            content.addArrangedSubview(sellerRanking(monthSales))
            content.addArrangedSubview(sectionLabel("Stock por reponer"))
            content.addArrangedSubview(lowStock())
        } catch { showError(error) }
    }

    private func metricCard(_ title: String, value: String, icon: String) -> UIView {
        let box = UIStackView()
        box.axis = .vertical
        box.spacing = 8
        box.alignment = .leading
        box.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        box.isLayoutMarginsRelativeArrangement = true
        box.backgroundColor = .secondarySystemBackground
        box.layer.cornerRadius = 14
        let symbol = UIImageView(image: UIImage(systemName: icon))
        symbol.tintColor = AppStyle.teal
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = AppStyle.muted
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = AppStyle.navy
        valueLabel.font = .systemFont(ofSize: 17, weight: .bold)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75
        [symbol, titleLabel, valueLabel].forEach(box.addArrangedSubview)
        return box
    }

    private func sectionLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = AppStyle.navy
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }

    private func weekChart(_ sales: [Venta]) -> UIView {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0 - 6, to: today) }
        let amounts = days.map { day in
            sales.filter { calendar.isDate($0.fecha, inSameDayAs: day) }
                .reduce(0) { $0 + $1.total }
        }
        let maxAmount = max(amounts.max() ?? 0, 1)
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .bottom
        row.distribution = .fillEqually
        row.spacing = 7
        row.heightAnchor.constraint(equalToConstant: 142).isActive = true
        for (index, day) in days.enumerated() {
            let column = UIStackView()
            column.axis = .vertical
            column.alignment = .center
            column.distribution = .fill
            column.spacing = 5
            let value = UILabel()
            value.text = amounts[index] > 0 ? String(format: "%.0f", amounts[index]) : "–"
            value.font = .systemFont(ofSize: 9, weight: .medium)
            value.textColor = AppStyle.muted
            let track = UIView()
            track.backgroundColor = UIColor.systemGray5
            track.layer.cornerRadius = 5
            track.heightAnchor.constraint(equalToConstant: 90).isActive = true
            track.widthAnchor.constraint(equalToConstant: 22).isActive = true
            let bar = UIView()
            bar.backgroundColor = AppStyle.teal
            bar.layer.cornerRadius = 5
            track.addSubview(bar)
            bar.translatesAutoresizingMaskIntoConstraints = false
            let height = CGFloat(max(4.0, 90.0 * amounts[index] / maxAmount))
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: track.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: track.trailingAnchor),
                bar.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                bar.heightAnchor.constraint(equalToConstant: height)
            ])
            let dayLabel = UILabel()
            dayLabel.text = day.weekdayInitial
            dayLabel.font = .systemFont(ofSize: 10, weight: .medium)
            dayLabel.textColor = AppStyle.muted
            [value, track, dayLabel].forEach(column.addArrangedSubview)
            row.addArrangedSubview(column)
        }
        return row
    }

    private func sellerRanking(_ sales: [Venta]) -> UIView {
        let grouped = Dictionary(grouping: sales.compactMap { sale -> (String, Double)? in
            guard let name = sale.vendedor?.nombre else { return nil }
            return (name, sale.total)
        }, by: { $0.0 })
        let ranking = grouped.map { (name: $0.key, total: $0.value.reduce(0) { $0 + $1.1 }) }
            .sorted { $0.total > $1.total }.prefix(5)
        if ranking.isEmpty { return emptyNote("Aún no hay ventas registradas este mes.") }
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        for (index, item) in ranking.enumerated() {
            let rank = UILabel()
            rank.text = "\(index + 1).  \(item.name)"
            let amount = UILabel()
            amount.text = AppStyle.money(item.total)
            amount.textColor = AppStyle.teal
            amount.font = .systemFont(ofSize: 14, weight: .semibold)
            let line = UIStackView(arrangedSubviews: [rank, amount])
            line.distribution = .equalSpacing
            stack.addArrangedSubview(line)
        }
        return stack
    }

    private func lowStock() -> UIView {
        do {
            let products = try SalesService.shared.products().filter { $0.stock <= 5 }
            guard !products.isEmpty else { return emptyNote("Todos los productos tienen stock suficiente.") }
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 9
            for product in products {
                let name = UILabel()
                name.text = product.nombre
                let units = UILabel()
                units.text = "\(product.stock) uds."
                units.textColor = .systemOrange
                let line = UIStackView(arrangedSubviews: [name, units])
                line.distribution = .equalSpacing
                stack.addArrangedSubview(line)
            }
            return stack
        } catch { return emptyNote("No se pudo cargar el inventario.") }
    }

    private func emptyNote(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = AppStyle.muted
        label.numberOfLines = 0
        return label
    }
}
