//
//  GithubIssue.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import UIKit
import  SafariServices

class GithubIssue: UIViewController {
    
    var repository: Repository?
    var issues: [Issue]?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        
        self.set(backgroundColor: UIColor(named: "theme-color") ?? .darkGray)
        self.set(titleColor: .white)
        self.show(viewOnGithub: true)
        self.fetchIssues()
       
    }
    
    private func fetchIssues() {
        guard let repository = repository else {
            return
        }
        Github.showIssues(for: repository) { result in
            switch result {
            case .success(let fetchedIssues):
                print("fetchedIssues: \(fetchedIssues)")
                self.issues = fetchedIssues
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if !fetchedIssues.isEmpty {
                        self.tableView.restore()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    SnackBoard.display(message: error.localizedDescription, mode: .error, duration: .middle)
                }
            }
        }
    }
    
    
    
    @discardableResult
    public func set(backgroundColor: UIColor) ->  GithubIssue {
        self.view.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func show(viewOnGithub: Bool) ->  GithubIssue {
        let button = UIBarButtonItem(title: "View on Github", style: .done, target: self, action: #selector(didViewOnGithubPressed))
        self.navigationItem.rightBarButtonItem  = button
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) ->  GithubIssue {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        return self
    }
    
    @discardableResult
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode) ->  GithubIssue {
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
        self.tableView.backgroundColor = UIColor(named: "theme-color")
        self.registerCells()
        
    }
    
    private func registerCells(){
        
        let RepositoryItem  =  UINib(nibName: "RepositoryItem", bundle: nil)
        self.tableView.register(RepositoryItem, forCellReuseIdentifier: "RepositoryItem")
    }
    
    @objc func didViewOnGithubPressed(){
        guard let url = URL(string: repository?.html_url ?? "") else { return }
        let sfvc = SFSafariViewController(url: url)
        self.present(sfvc, animated: true, completion: nil)
    }
    
}


extension GithubIssue: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies height for section in GithubIssue
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /// This method specifies the view for header  in GithubIssue
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
    
    /// This method specifiesnumber of rows in GithubIssue
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ((issues?.isEmpty) != nil) {
            self.tableView.setEmptyMessage("No Issues found.")
        } else{
            self.tableView.restore()
        }
        return issues?.count ?? 0
        
        
    }
    
    /// This method specifies the height for row in GithubIssue
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for user  in GithubIssue
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let repositoryItem = tableView.dequeueReusableCell(withIdentifier: "RepositoryItem", for: indexPath) as? RepositoryItem ,  let issue = self.issues?[indexPath.row] {
            
            repositoryItem.issue = issue
            return repositoryItem
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
