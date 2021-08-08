//
//  MyRepos.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import UIKit

class MyRepos: UIViewController {

    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var repositories: [Repository]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.set(backgroundColor: UIColor(named: "theme-color") ?? .darkGray)
        self.set(titleColor: .white)
        self.pullYourOwnRepositories()
    }

    @discardableResult
    public func set(backgroundColor: UIColor) ->  MyRepos {
        self.view.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) ->  MyRepos {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        return self
    }

    @discardableResult
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode) ->  MyRepos {
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
    
    private func pullYourOwnRepositories() {
        
        if let user = LoggedInUser.information() {
            Github.pullOwnRepositories(for: user) { result in
              
                switch result {
                
                case .success(let fetchedRepositories):
                 
                    self.repositories = fetchedRepositories
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        SnackBoard.display(message: error.localizedDescription, mode: .error, duration: .middle)
                    }
                }
            }
        }
    }
    
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.registerCells()
     
    }
    
    private func registerCells(){
      
        let RepositoryItem  =  UINib(nibName: "RepositoryItem", bundle: nil)
        self.tableView.register(RepositoryItem, forCellReuseIdentifier: "RepositoryItem")
    }

}


extension MyRepos: UITableViewDelegate , UITableViewDataSource {
    
    
    /// This method specifies height for section in Home
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /// This method specifies the view for header  in Home
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 0.5))
        return returnedView
    }
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifiesnumber of rows in Home
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return repositories?.count ?? 0

    }
    
    /// This method specifies the height for row in Home
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for user  in Home
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let repositoryItem = tableView.dequeueReusableCell(withIdentifier: "RepositoryItem", for: indexPath) as? RepositoryItem  {
            
            let repository: Repository?
            
            repository = self.repositories?[indexPath.row]
            repositoryItem.repository = repository
            return repositoryItem
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? RepositoryItem {
            let issues = GithubIssue()
            issues.title = "Github Issues"
            issues.repository = cell.repository
            self.navigationController?.pushViewController(issues, animated: true)
        }
       
    }
}
