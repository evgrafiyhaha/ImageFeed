import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        
        let imagesListViewController = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    // MARK: - Private Methods
    
    private func setUpTabBar() {
        self.tabBar.tintColor = .white
        self.tabBar.backgroundColor = .ypBlack
        self.tabBar.barTintColor = .ypBlack
        self.tabBar.isTranslucent = false
    }
}
