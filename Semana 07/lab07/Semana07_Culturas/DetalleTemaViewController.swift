import UIKit

class DetalleTemaViewController: UIViewController {
    var tema: Tema?

    @IBOutlet private weak var labelTituloTema: UILabel!
    @IBOutlet private weak var labelDescripcionTema: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tema else {
            navigationController?.popViewController(animated: false)
            return
        }

        title = tema.titulo
        labelTituloTema.text = tema.titulo
        labelDescripcionTema.text = tema.contenido
    }
}
