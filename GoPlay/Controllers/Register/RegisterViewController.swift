//
//  RegisterViewController.swift
//  GoPlay
//
//  Created by Darren Borromeo on 12/1/2023.
//

/*

 Allows the user to register into firebase.
 
 Segues:
    - Login -> Here.
 
 Classes:
    - DatabaseManager.
    - StorageManager.
 
 */

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    // MARK: - Variables
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name ..."
        field.backgroundColor = .white
        
        // Adds left buffer for text.
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name ..."
        field.backgroundColor = .white
        
        // Adds left buffer for text.
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        
        return field
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
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
        
        // Add button targets.
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        // Enable user interaction with views.
        imageView.isUserInteractionEnabled  = true
        scrollView.isUserInteractionEnabled = true
        
        // Add delegates.
        firstNameField.delegate = self
        lastNameField.delegate  = self
        emailField.delegate     = self
        passwordField.delegate  = self
        
        // Add gesture for tapping image.
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
        
        /// Add subviews.
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Add frames.
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(
            x: (scrollView.width-size)/2,
            y: 50,
            width: size,
            height: size)
        imageView.layer.cornerRadius = imageView.width/2.0  // Makes image circular.
        
        firstNameField.frame = CGRect(
            x: 30,
            y: imageView.bottom+10,
            width: scrollView.width-60 ,
            height: 52)
        
        lastNameField.frame = CGRect(
            x: 30,
            y: firstNameField.bottom+10,
            width: scrollView.width-60 ,
            height: 52)
        
        emailField.frame = CGRect(
            x: 30,
            y: lastNameField.bottom+10,
            width: scrollView.width-60 ,
            height: 52)
        
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.bottom+10,
            width: scrollView.width-60 ,
            height: 52)
        
        registerButton.frame = CGRect(
            x: 30,
            y: passwordField.bottom+10,
            width: scrollView.width-60 ,
            height: 52)
    }
    
    // MARK: - Actions
    
    /// The user has tapped their profile picture --> change profile picture.
    /// The gesture and user interaction in viewDidLoad enables tapping a picture.
    /// The extension below enables the delegate and assosciated functions.
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    /// Register the user into the firebase and the realtime database (both are different and needed).
    @objc private func didTapRegisterButton() {
        // Get off keyboard.
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // Email and password authenticator.
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text,
                let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Login.
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else { return }  // Create strong self.
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }

            // User already exists! - cancel registration.
            guard !exists else {
                self?.alertUserLoginError(message: "A user account with that email address already exists.")
                return
            }

            // User doesn't exist.
            // Insert user into firebase.
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                // Checks if there is an authResult and no error.
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }

                // Insert user into database.
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        guard let image = strongSelf.imageView.image, let data = image.pngData() else {
                            // Failed getting profile picture from image view.
                            return
                        }
                        
                        // Success getting profile picture from image view.
                        // Attempt to upload picture into firebase storage.
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    }
                })//End - insertUser.

                // The user has registered, get off registration view.
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })//End - createUser.
        })//End - userExists.
    }//End - didTapRegisterButton().
    
    /// Creates an alert for the user if an error occurs.
    func alertUserLoginError(message: String = "Please enter all information to register.") {
        let alert = UIAlertController(
            title: "Whoops!",
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}

// MARK: - Extensions

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField { lastNameField.becomeFirstResponder() }
        else if textField == lastNameField { emailField.becomeFirstResponder() }
        else if textField == emailField { passwordField.becomeFirstResponder() }
        else if textField == passwordField { didTapRegisterButton() }
        
        return true
    }
}


/// This extension requires a image view, gesture, and 'user interaction enabled' to work.
/// It handles when a user taps an image. For intents and purposes, the image becomes a button.
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Called when a user wants to change their profile picture.
    /// Gives them the option to cancel, take photo, or choose photo.
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: "How would you like to select a profile picture?",
            preferredStyle: .actionSheet)
        
        // Add actions to action sheet.
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    /// Open camera so user can take a profile picture.
    /// Will crash if camera isn't ready.
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType    = .camera
        vc.delegate      = self     // Requires UINavigationControllerDelegate
        vc.allowsEditing = true     // Allows user to crop photo.
        present(vc, animated: true)
    }
    
    /// Open photo picker so user can choose a profile picture.
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType    = .photoLibrary
        vc.delegate      = self      // Requires UINavigationControllerDelegate
        vc.allowsEditing = true      // Allows user to crop photo.
        present(vc, animated: true)
    }
    
    /// Called when a user has picked an image from the image picker.
    /// Set that image as their profile picture.
    ///   - @return: info - info of chosen image.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
            // Edited image = allows you to crop the image. Original image is the full image.
        self.imageView.image = selectedImage
    }
    
    /// Called when a user cancels taking a picture.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

