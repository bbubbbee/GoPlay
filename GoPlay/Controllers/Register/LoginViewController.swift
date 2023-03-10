//
//  LoginViewController.swift
//  GoPlay
//
//  Created by Darren Borromeo on 12/1/2023.
//


/*
 
 Allows the user to login.
 
 Segues:
    - Map -> Here: If the user is not logged in, go here.
        Map is the first view opened. Consequently, it has to validate that the user is logged in.
    - Here -> Register: Navigation bar button.
 
 Classes:
    - DatabaseManager.
    - StorageManager.
 
 */

import UIKit
import FirebaseAuth
import JGProgressHUD
import FirebaseStorage

class LoginViewController: UIViewController {
    
    // MARK: - Variables
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address ..."
        field.backgroundColor = .white
        
        // Adds left buffer for text.
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password ..."
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        // Adds left buffer for text.
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Log In"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegisterButton))
        
        // Button targets.
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        // Add delegates.
        emailField.delegate    = self
        passwordField.delegate = self
        
        // Add subviews.
        view.addSubview(scrollView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Add frames.
        scrollView.frame = view.bounds
        
        emailField.frame = CGRect(
            x: 30,
            y: 100,
            width: scrollView.width-60,
            height: 52)

        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom+10,
            width: scrollView.width-60,
            height: 52)

        loginButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom+10,
            width: scrollView.width-60,
            height: 52)
    }
    
    // MARK: - Actions
    
    @objc private func didTapRegisterButton() {
        let vc = RegisterViewController()
        vc.title = "Register User"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapLoginButton() {
        // Remove keyboard.
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        // Email and password authenticator.
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty,
              !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase login.
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }

            let user = result.user
            print("Logged in user: \(user)")
            
            UserDefaults.standard.set(email, forKey: "email")

            // The user has logged on, get off login view.
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    /// Alert the user because an error has ocurred.
    func alertUserLoginError() {
        let alert = UIAlertController(
            title: "Whoops!",
            message: "Please enter all information to log in.",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}

// MARK: - Extensions

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField { passwordField.becomeFirstResponder() }
        else if textField == passwordField { didTapLoginButton() }
        
        return true
    }
}
