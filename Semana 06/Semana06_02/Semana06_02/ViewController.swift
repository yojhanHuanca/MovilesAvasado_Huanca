import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tfApellido: UITextField!
    @IBOutlet weak var tfNombre: UITextField!
    @IBOutlet weak var tfDni: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Acción del botón: Se deja vacía porque el Segue sale directamente
    // del botón en el Storyboard y se activa solo.
    @IBAction func btnContinuar(_ sender: Any) {
    }

    // Este método lo ejecuta Swift AUTOMÁTICAMENTE antes de cambiar de pantalla
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgConfirmacion" {
            if let oPantalla2 = segue.destination as? ViewControllerConfirmacion {
                
                // 1. Armamos el objeto con los datos tipeados
                let oCliente = ClienteModel(
                    pCodigo: 0,
                    pApellido: self.tfApellido.text ?? "",
                    pNombre: self.tfNombre.text ?? "",
                    pDni: self.tfDni.text ?? ""
                )
                
                // 2. Le pasamos el cliente a la segunda pantalla
                oPantalla2.pCliente = oCliente
            }
        }
    }
}
