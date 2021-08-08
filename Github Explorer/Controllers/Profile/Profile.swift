//
//  Profile.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import UIKit
import SafariServices

class Profile: UIViewController {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.set(backgroundColor: UIColor(named: "theme-color") ?? .darkGray)
        self.set(titleColor: .white)
        self.setupUser()
        
        
    }

    @discardableResult
    public func set(backgroundColor: UIColor) ->  Profile {
        self.view.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) ->  Profile {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        return self
    }

    @discardableResult
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode) ->  Profile {
        if navigationController != nil{
            navigationItem.title = title
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }
        return self
    }
    
    private func setupUser() {
        if let user = LoggedInUser.information() {
           
            self.name.text = user.name
            self.location.text = user.location
            self.followersButton.setTitle("   \(user.followers) Followers", for: .normal)
            self.followingButton.setTitle("   \(user.following) Followings", for: .normal)
            let url = URL(string: user.avatar_url)
            avatar.cf.setImage(with: url, placeholder: UIImage(named: "defaultAvatar.png", in: nil, compatibleWith: nil))
            
        }
    }
    
 
    @IBAction func didViewOnGithubPressed(_ sender: Any) {
            guard let url = URL(string: LoggedInUser.information().html_url ) else { return }
            let sfvc = SFSafariViewController(url: url)
            self.present(sfvc, animated: true, completion: nil)
    }
}
