import UIKit

struct Tema {
    let titulo: String
    let contenido: String
}

final class CulturaHeaderCell: UITableViewCell {
    @IBOutlet weak var imagenCultura: UIImageView!
    @IBOutlet weak var labelNombreCultura: UILabel!
    @IBOutlet weak var labelRegionCultura: UILabel!
    @IBOutlet weak var labelDescripcionCultura: UILabel!

    func configurar(con cultura: Cultura) {
        imagenCultura.image = cultura.foto
        imagenCultura.contentMode = .scaleAspectFill
        imagenCultura.layer.cornerRadius = 14
        imagenCultura.clipsToBounds = true
        labelNombreCultura.text = cultura.nombre
        labelRegionCultura.text = cultura.region
        labelDescripcionCultura.text = cultura.descripcion
        selectionStyle = .none
    }
}

class DetalleCulturaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cultura: Cultura?
    private var temas: [Tema] = []
    private var temaSeleccionado: Tema?

    @IBOutlet private weak var tablaDetalle: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let cultura else {
            navigationController?.popViewController(animated: false)
            return
        }
        guard let tablaDetalle else {
            print("Falta conectar tablaDetalle en Main.storyboard")
            navigationController?.popViewController(animated: false)
            return
        }

        title = cultura.nombre
        cargarTemas(para: cultura)
        tablaDetalle.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return cultura == nil ? 0 : 1
        case 1: return temas.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "detalleCulturaHeader",
                for: indexPath
            ) as! CulturaHeaderCell
            if let cultura {
                cell.configurar(con: cultura)
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "tema", for: indexPath)
        var contenido = cell.defaultContentConfiguration()
        contenido.text = temas[indexPath.row].titulo
        cell.contentConfiguration = contenido
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Temas" : nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? UITableView.automaticDimension : 52
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 360 : 52
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        temaSeleccionado = temas[indexPath.row]
        performSegue(withIdentifier: "detalleTemaSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "detalleTemaSegue",
              let detalle = segue.destination as? DetalleTemaViewController,
              let temaSeleccionado else { return }

        detalle.tema = temaSeleccionado
    }

    private func cargarTemas(para cultura: Cultura) {
        switch cultura.nombre {
        case "Caral":
            temas = [
                Tema(titulo: "Arquitectura", contenido: "Caral tuvo plazas circulares y edificios ceremoniales construidos con piedra y barro."),
                Tema(titulo: "Agricultura", contenido: "Sus habitantes cultivaron productos como algodón, zapallo y frijol en el valle de Supe."),
                Tema(titulo: "Organizacion social", contenido: "La construccion de sus edificios muestra el trabajo colectivo y la organizacion de sus habitantes.")
            ]
        case "Chavin":
            temas = [
                Tema(titulo: "Religion", contenido: "Chavin de Huantar fue un importante centro ceremonial visitado por personas de distintas regiones."),
                Tema(titulo: "Escultura", contenido: "Sus esculturas de piedra representan seres humanos y animales con rasgos simbolicos."),
                Tema(titulo: "Arquitectura", contenido: "El centro ceremonial cuenta con plazas, galerias interiores y construcciones de piedra.")
            ]
        case "Nazca":
            temas = [
                Tema(titulo: "Lineas de Nazca", contenido: "Son figuras y lineas trazadas sobre el desierto, visibles con claridad desde zonas elevadas."),
                Tema(titulo: "Ceramica", contenido: "La ceramica Nazca destaca por sus formas variadas y sus diseños pintados con varios colores."),
                Tema(titulo: "Sistemas de agua", contenido: "Construyeron acueductos y canales subterraneos para transportar agua en una region seca.")
            ]
        case "Moche":
            temas = [
                Tema(titulo: "Ceramica", contenido: "Los Moche elaboraron vasijas con retratos y escenas de la vida cotidiana."),
                Tema(titulo: "Metalurgia", contenido: "Trabajaron metales para fabricar adornos y objetos ceremoniales."),
                Tema(titulo: "Agricultura", contenido: "Usaron canales de irrigacion para cultivar en los valles de la costa norte.")
            ]
        case "Inca":
            temas = [
                Tema(titulo: "Qhapaq Nan", contenido: "La red de caminos conectaba Cusco con las distintas regiones del Tahuantinsuyo."),
                Tema(titulo: "Agricultura", contenido: "Andenes y canales permitieron cultivar en terrenos montañosos."),
                Tema(titulo: "Organizacion del Tahuantinsuyo", contenido: "El territorio se organizo en regiones conectadas por caminos y centros administrativos.")
            ]
        default:
            temas = [Tema(titulo: "Historia", contenido: cultura.descripcion)]
        }
    }
}
