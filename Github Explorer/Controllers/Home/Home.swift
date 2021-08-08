//
//  Home.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import UIKit

class Home: UIViewController {

    // MARK: - Declaration of Variables
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    var repositories: [Repository]?
    var filteredRepositories: [Repository] = [Repository]()
    
    // MARK: - View controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupSearchBar()
        self.searchRepositories(for: "facebook")
        self.set(backgroundColor: UIColor(named: "theme-color") ?? .darkGray)
        self.set(titleColor: .white)
    }

    @discardableResult
    public func set(backgroundColor: UIColor) ->  Home {
        self.view.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) ->  Home {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        return self
    }

    @discardableResult
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode) ->  Home {
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
    
    private func setupSearchBar(){
        // SearchBar Apperance
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchController.searchBar.barTintColor = .systemBackground
        } else {}
        if #available(iOS 11.0, *) {
            if navigationController != nil{
                self.navigationItem.searchController = self.searchController
            }else{
                if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    if #available(iOS 13.0, *) {textfield.textColor = .label } else {}
                    if let backgroundview = textfield.subviews.first{
                        backgroundview.backgroundColor = .white
                        backgroundview.layer.cornerRadius = 10
                        backgroundview.clipsToBounds = true
                    }}
                self.tableView.tableHeaderView = self.searchController.searchBar
            }} else {}
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
   
    private func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
    private func searchRepositories(for keyword: String ) {
        
        Github.searchRepositories(with: keyword, order: .asc) { result in
            switch result {
            
            case .success(let fetchedRepositories):
                print("fetchedRepositories: \(fetchedRepositories)")
                DispatchQueue.main.async {
                    if self.isSearching() {
                        self.filteredRepositories = fetchedRepositories
                    }else{
                        self.repositories = fetchedRepositories
                    }
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


extension Home: UITableViewDelegate , UITableViewDataSource {
    
    
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
        
        if isSearching() {
            return filteredRepositories.count
        }else{
            return repositories?.count ?? 0
        }
        
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
            if isSearching() {
                repository = self.filteredRepositories[indexPath.row]
                repositoryItem.repository = repository
                return repositoryItem
            }else{
                repository = self.repositories?[indexPath.row]
                repositoryItem.repository = repository
                return repositoryItem
            }
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

extension Home : UISearchBarDelegate, UISearchResultsUpdating {
    

    public func updateSearchResults(for searchController: UISearchController) {
        
        guard let keyword = searchController.searchBar.text?.lowercased() else { return }
        if !keyword.isEmpty  {
            self.searchRepositories(for: keyword)
        }else{
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
}
