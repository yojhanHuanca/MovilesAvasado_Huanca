import UIKit

final class MainTabBarController: UITabBarController {
    let currentUser: Usuario

    init(user: Usuario) {
        currentUser = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) no está implementado")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = AppStyle.teal
        tabBar.backgroundColor = .systemBackground

        if currentUser.rol == AppRole.supervisor {
            viewControllers = [
                navigation(DashboardViewController(user: currentUser), title: "Resumen", icon: "chart.bar.fill"),
                navigation(SalesListViewController(user: currentUser, supervisorMode: true), title: "Ventas", icon: "receipt"),
                navigation(ProductsViewController(user: currentUser), title: "Productos", icon: "shippingbox"),
                navigation(ClientsViewController(user: currentUser), title: "Clientes", icon: "person.2"),
                navigation(AccountViewController(user: currentUser), title: "Cuenta", icon: "person.crop.circle")
            ]
        } else {
            viewControllers = [
                navigation(ProductsViewController(user: currentUser), title: "Productos", icon: "shippingbox"),
                navigation(ClientsViewController(user: currentUser), title: "Clientes", icon: "person.2"),
                navigation(NewSaleViewController(user: currentUser), title: "Venta", icon: "plus.circle.fill"),
                navigation(SalesListViewController(user: currentUser, supervisorMode: false), title: "Mis ventas", icon: "receipt"),
                navigation(AccountViewController(user: currentUser), title: "Cuenta", icon: "person.crop.circle")
            ]
        }
    }

    private func navigation(_ root: UIViewController, title: String, icon: String) -> UINavigationController {
        root.title = title
        let controller = UINavigationController(rootViewController: root)
        controller.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: nil)
        return controller
    }
}
