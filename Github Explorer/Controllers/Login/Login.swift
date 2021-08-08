//
//  Login.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import UIKit

class Login: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerObservers()
    }
    
    fileprivate func registerObservers(){
        //Register Delegates
        username.delegate = self
        password.delegate = self
        
        //Register Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedArround()
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {}
    
    fileprivate func hideKeyboardWhenTappedArround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc  func dismissKeyboard() {
        
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    
   
    
    @IBAction func didLogInPressed(_ sender: Any) {
        guard let username = username.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        guard let password = password.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return
        }
        
        self.login(with:username, and: password)
    }
   
    @IBAction func didSignUpPressed(_ sender: Any) {
        SnackBoard.display(message: "No Action added yet.", mode: .info, duration: .short)
    }
    
    private func login(with username: String, and password: String) {
        
        if username.isEmpty {
            
            SnackBoard.display(message: "Username cannot be empty", mode: .error, duration: .short)
            
        }else{
         
                DispatchQueue.main.async {
                    
                    Github.login(withUser: username) { result in
                        
                        switch result {
                        
                        case .success(let user):
                            print("user is: \(user)")
                            
                            DispatchQueue.main.async {
                                SnackBoard.display(message: "Login successfully", mode: .success, duration: .short)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tabbar") as? Tabbar {
                                        tabViewController.modalPresentationStyle = .fullScreen
                                        self.present(tabViewController, animated: true, completion: nil)
                                    }
                                }
                            }
                            
                        case .failure(let error):
                            DispatchQueue.main.async {
                                SnackBoard.display(message: error.localizedDescription, mode: .error, duration: .middle)
                            }
                        }
                        
                    }
                   
                   
                }
    }
    }
    
    
}

extension Login: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
