//
//  ViewController.swift
//  Semana07_Culturas
//
//  Created by Tecsup on 13/10/26.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var tablaCulturas: UITableView!

    private let listaCulturas = [
        Cultura(nombre: "Caral", region: "Valle de Supe, Lima", descripcion: "Caral fue una de las civilizaciones mas antiguas de America. Sus habitantes construyeron una ciudad con plazas y edificios ceremoniales en el valle de Supe.", foto: UIImage(named: "imagen1")),
        Cultura(nombre: "Chavin", region: "Ancash", descripcion: "Chavin de Huantar fue un importante centro ceremonial. Su arte en piedra y sus galerias muestran la influencia que esta cultura tuvo en los Andes.", foto: UIImage(named: "imagen2")),
        Cultura(nombre: "Nazca", region: "Ica", descripcion: "La cultura Nazca es conocida por sus geoglifos trazados en el desierto y por su ceramica de muchos colores. Tambien desarrollo sistemas para aprovechar el agua.", foto: UIImage(named: "imagen3")),
        Cultura(nombre: "Moche", region: "La Libertad y Lambayeque", descripcion: "Los Moche destacaron por sus ceramicas, sus trabajos en metal y sus canales de irrigacion. En esta region se encuentran las tumbas del Senor de Sipan.", foto: UIImage(named: "imagen4")),
        Cultura(nombre: "Inca", region: "Cusco y los Andes", descripcion: "Los incas organizaron el Tahuantinsuyo desde Cusco y conectaron sus territorios con una extensa red de caminos conocida como Qhapaq Nan.", foto: UIImage(named: "imagen5"))
        ]

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaCulturas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        let cultura = listaCulturas[indexPath.row]
        cell.textLabel?.text = cultura.nombre
        cell.detailTextLabel?.text = cultura.region
        cell.imageView?.image = cultura.foto
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Culturas Peruanas"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "detalleCulturaSegue",
              let detalle = segue.destination as? DetalleCulturaViewController,
              let celda = sender as? UITableViewCell,
              let indexPath = tablaCulturas.indexPath(for: celda) else { return }

        detalle.cultura = listaCulturas[indexPath.row]
    }

}

