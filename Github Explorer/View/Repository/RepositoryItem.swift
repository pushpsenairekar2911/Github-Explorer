//
//  RepositoryItem.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import UIKit

class RepositoryItem: UITableViewCell {

    
    @IBOutlet private weak var repo: UILabel!
    @IBOutlet weak var repoType: UILabel!
    @IBOutlet private weak var information: UILabel!
    @IBOutlet private weak var language: UILabel!
    @IBOutlet private weak var stars: UILabel!
    @IBOutlet private weak var forks: UILabel!
    @IBOutlet private weak var pullRequests: UILabel!
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var updatedAt: UILabel!
    
     
     var repository: Repository? {
         didSet {
             
             if let name = repository?.full_name {
                 self.repo.text = name
             }
             
             if let isPrivate = repository?.isPrivate {
                 if isPrivate == true {
                     self.repoType.text = "Private"
                 }else{
                     self.repoType.text = "Public"
                 }
             }
             
             if let information = repository?.description {
                 self.information.text = information
             }
             
             if let language = repository?.language {
                 self.language.text = language
             }
             
             if let starsCount = repository?.score  {
                 self.stars.text = String(starsCount)
             }
             
             if let forks = repository?.forks {
                 self.forks.text = String(forks)
             }

            self.bottomStack.isHidden = false
            self.createdAt.isHidden = true
            self.updatedAt.isHidden = true
         }
     }
    
    
    var issue: Issue? {
        didSet {
            self.bottomStack.isHidden = true
            self.createdAt.isHidden = false
            self.updatedAt.isHidden = false
            
            if let title = issue?.title {
                self.repo.text = title
            }
            
            if let state = issue?.state {
                self.repoType.text = state
            }
            
            if let assignee = issue?.assignee {
                if assignee != "" {
                    self.information.text = assignee
                }else{
                    self.information.text = "Not assigned yet."
                }
            }
            
            if let createdAt = issue?.created_at {
                self.createdAt.text = "Created At: \(createdAt)"
            }
            
            if let updatedAt = issue?.updated_at {
                self.updatedAt.text = "Updated At: \(updatedAt)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
