import UIKit

class DetalleCulturaViewController: UIViewController {
    var cultura: Cultura!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalle"
        view.backgroundColor = .systemBackground
        configurarVista()
    }

    private func configurarVista() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contenido = UIStackView()
        contenido.axis = .vertical
        contenido.spacing = 16
        contenido.translatesAutoresizingMaskIntoConstraints = false

        let imagen = UIImageView(image: cultura.foto)
        imagen.contentMode = .scaleAspectFill
        imagen.clipsToBounds = true
        imagen.layer.cornerRadius = 12
        imagen.backgroundColor = .secondarySystemBackground
        imagen.heightAnchor.constraint(equalToConstant: 260).isActive = true
        imagen.accessibilityLabel = "Imagen de \(cultura.nombre)"

        let nombre = UILabel()
        nombre.text = cultura.nombre
        nombre.font = .preferredFont(forTextStyle: .largeTitle)
        nombre.font = .systemFont(ofSize: 32, weight: .bold)
        nombre.numberOfLines = 0

        let regionTitulo = UILabel()
        regionTitulo.text = "REGION"
        regionTitulo.font = .preferredFont(forTextStyle: .caption1)
        regionTitulo.textColor = .secondaryLabel

        let region = UILabel()
        region.text = cultura.region
        region.font = .preferredFont(forTextStyle: .title3)
        region.numberOfLines = 0

        let descripcionTitulo = UILabel()
        descripcionTitulo.text = "DESCRIPCION"
        descripcionTitulo.font = .preferredFont(forTextStyle: .caption1)
        descripcionTitulo.textColor = .secondaryLabel

        let descripcion = UILabel()
        descripcion.text = cultura.descripcion
        descripcion.font = .preferredFont(forTextStyle: .body)
        descripcion.numberOfLines = 0

        [imagen, nombre, regionTitulo, region, descripcionTitulo, descripcion].forEach {
            contenido.addArrangedSubview($0)
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contenido)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contenido.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contenido.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contenido.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contenido.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contenido.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }
}