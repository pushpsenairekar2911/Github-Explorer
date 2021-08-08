

// MARK: - Importing Frameworks.

import UIKit

/*  ----------------------------------------------------------------------------------------- */

public enum Controller : String {
    case home = "home"
    case myrepos = "my_repos"
    case profile = "profile"
}


/// **Tabbar**  is a way to launch a fully working chat application using the UI Kit. In Tabbar all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
@objc  class Tabbar: UITabBarController {
    
  
    // MARK: - Declaration of Variables
    
    // Declaration of UINavigationController's  to Embed VC's
     let homeNavigation = UINavigationController()
     let myRepoNavigation = UINavigationController()
     let profileNavigation = UINavigationController()
    
    //  Initialization of variables for UIScreens
    var home:Home = Home()
    var myRepos: MyRepos = MyRepos()
    var profile:Profile =  Profile()

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        var controllers = [UIViewController]()
        controllers.append(homeNavigation)
        controllers.append(myRepoNavigation)
        controllers.append(profileNavigation)
        set(controllers: controllers)
    }
    
    // MARK: -  Methods
    @discardableResult
    public func set(tabbarColor: UIColor) ->  Tabbar {
        self.tabBar.barTintColor = tabbarColor
        return self
    }
    
    
    @discardableResult
    public func set(selectedIconColor: UIColor) ->  Tabbar {
        self.tabBar.tintColor = selectedIconColor
        return self
    }
    
    @discardableResult
    public func set(unselectedIconColor: UIColor) ->  Tabbar {
        self.tabBar.unselectedItemTintColor = unselectedIconColor
        return self
    }
    
    @discardableResult
    public func setTitle(forHomeTab: String?) ->  Tabbar {
        self.home.tabBarItem.title = forHomeTab
        return self
    }
    
    @discardableResult
    public func setTitle(forMyRepoTab: String?) ->  Tabbar {
        self.myRepos.tabBarItem.title = forMyRepoTab
        return self
    }
    
    @discardableResult
    public func setTitle(forProfileTab: String?) ->  Tabbar {
        self.profile.tabBarItem.title = forProfileTab
        return self
    }
    
    @discardableResult
    public func setIcon(forHomeTab: UIImage) ->  Tabbar {
        self.home.tabBarItem.image = forHomeTab
        return self
    }
    
    @discardableResult
    public func setIcon(forMyRepoTab: UIImage) ->  Tabbar {
        self.myRepos.tabBarItem.image = forMyRepoTab
        return self
    }
    
    @discardableResult
    public func setIcon(forProfileTab: UIImage) ->  Tabbar {
        self.profile.tabBarItem.image = forProfileTab
        return self
    }
    
  
    /**
     This methods sets the UI Screens tabs for the view controllers which user wants to display in Tabbar.
     - Parameter controllers: This takes the array of UIScreens view controllers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [Tabbar Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @discardableResult
    @objc public func set(controllers: [UIViewController]?) ->  Tabbar {
       
        // Adding Navigation controllers for view controllers.
        homeNavigation.viewControllers = [home]
        myRepoNavigation.viewControllers = [myRepos]
        profileNavigation.viewControllers = [profile]
      
        self.setIcon(forHomeTab: UIImage(systemName: "house.fill") ?? UIImage())
        self.setTitle(forHomeTab: "Home")
        
        self.setIcon(forMyRepoTab: UIImage(systemName: "star.fill") ?? UIImage())
        self.setTitle(forMyRepoTab: "My Repos")
        
        self.setIcon(forProfileTab: UIImage(systemName: "person.crop.circle") ?? UIImage())
        self.setTitle(forProfileTab: "Profile")
       
        // Setting title and  LargeTitleDisplayMode for view controllers.
        home.set(title: "Home", mode: .automatic)
        myRepos.set(title: "My Repos", mode: .automatic)
        profile.set(title: "Profile", mode: .automatic)


        // Setting tabbar icon colors
        self.set(selectedIconColor: .white)
        self.set(unselectedIconColor: UIColor(white: 0.8, alpha: 0.8))
        
 
        // Adding view controllers in Tabbar
        self.viewControllers = controllers
        
        return self
    }
    
    override func viewWillLayoutSubviews() {
        self.set(tabbarColor: UIColor(named: "theme-color") ?? .darkGray)
    }


}

/*  ----------------------------------------------------------------------------------------- */
