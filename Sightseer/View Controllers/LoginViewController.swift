//
//  LoginViewController.swift
//  Traveller
//
//  Created by Anthony on 25/09/19.
//  Copyright © 2019 EmeraldApps. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit


class LoginViewController: UIViewController {

    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHC: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!
    @IBOutlet weak var passwordTextField: UITextField!
    var logInIsSelected = true
    var activitySpinner = CustomActivityIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    /// text field validation vars
    var areTextFieldsComplete = false
    var textFieldErrors = [String]()
    var emailError = "Invalid email"
    var passwordError = "Password field must contain at least 8 characters"
    var passwordsDontMatch = "Passwords must match"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activitySpinner)
        activitySpinner.center = view.center
        setUpTabBarAppearance()
        setUpSegmentedControl()
        setUpContainerView()
        setUpButtons()
        setUpLabels()
        setUpTextFields()
        addObservers()
        hideKeyboardWhenTapped()
        view.backgroundColor = UIColor(named: "LoginBackground")
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// check if users already authenticated
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "toHome", sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObservers()
    }
    
    // MARK: - Text field validation
    func validateRegisterTextFields() -> Bool {
            textFieldErrors = [String]()
            areTextFieldsComplete = true
            if emailTextField.text?.count ?? 0 < 8 {
                areTextFieldsComplete = false
                textFieldErrors.append(emailError)
            }
            if passwordTextField.text?.count ?? 0 < 8 {
                areTextFieldsComplete = false
                textFieldErrors.append(passwordError)
            }
            if confirmPasswordLabel.text?.count ?? 0 < 8 {
            areTextFieldsComplete = false
            textFieldErrors.append(emailError)
            }
            if passwordTextField.text != confirmPasswordTextField.text {
            areTextFieldsComplete = false
            textFieldErrors.append(passwordsDontMatch)
            }
            if !areTextFieldsComplete {
                var textFieldErrorMessage = ""
                for message in textFieldErrors {
                    textFieldErrorMessage += "\u{2022} \(message)\n"
                }
                presentAlert(title: "Please fix the errors below", message: textFieldErrorMessage)
            }
            return areTextFieldsComplete
    }
    
    // MARK: - Register
    func register(){
        loginButton.disable()
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        if validateRegisterTextFields() {
            activitySpinner.startAnimating()
            
            Service.sharedInstance.createUserWithEmail(email: email, password: password, vc: self) {
                [weak self](succeeded) in
                
                guard let this = self else {return}
                if succeeded {
                   this.performSegue(withIdentifier: "toHome", sender: this)
                }
                this.loginButton.enable()
                this.activitySpinner.stopAnimating()
            }
        }
    }
    
    // MARK: - Login
    /// login with email and password
    func login(){
        activitySpinner.startAnimating()
        loginButton.disable()
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
            Service.sharedInstance.signInUserWithEmail(email: email, password: password, vc: self) {[weak self] (succeeded) in
            guard let this = self else {return}
            if succeeded {
                this.performSegue(withIdentifier: "toHome", sender: this)
            }
            this.loginButton.enable()
            this.activitySpinner.stopAnimating()
        }
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonClicked(_ sender: Any) {
        if logInIsSelected {
            login()
        } else {
            register()
        }
    }

    
    @IBAction func facebookLoginButtonClicked(_ sender: Any) {
        Service.sharedInstance.loginWithFacebook(vc: self)
        }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        loginSegmentedControl.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            
            /// delaying interaction to prevent any potential UI bugs
            self.loginSegmentedControl.isUserInteractionEnabled = true
        }
        switch sender.selectedSegmentIndex {
         case 0:
             logInIsSelected = true
             loginButton.setTitle("Login", for: .normal)
             removePasswordField()
             break
         case 1:
             logInIsSelected = false
             loginButton.setTitle("Register", for: .normal)
             addPasswordField()
             break
         default:
             print("Unknown index")
         }
    }
    
    // MARK: - Change Container Contents
    func addPasswordField(){
        containerViewHC.constant = 290
        confirmPasswordTextField.isEnabled = true
        confirmPasswordLabel.isEnabled = true
        confirmPasswordLabel.isHidden = false
        confirmPasswordTextField.isHidden = false
    }
    
    func removePasswordField(){
        containerViewHC.constant = 210
        confirmPasswordTextField.isEnabled = false
        confirmPasswordLabel.isEnabled = false
        confirmPasswordLabel.isHidden = true
        confirmPasswordTextField.isHidden = true
    }
    
    // MARK: - View Setup
    func setUpSegmentedControl(){
        let attributes = [ NSAttributedString.Key.foregroundColor : UIColor(named: "AppPrimary"),
                           NSAttributedString.Key.font : UIFont(name: "Futura", size: 14.0)];
         let attributesSelected = [ NSAttributedString.Key.foregroundColor : UIColor.white,
         NSAttributedString.Key.font : UIFont(name: "Futura", size: 14.0)];
        loginSegmentedControl.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        loginSegmentedControl.setTitleTextAttributes(attributesSelected as [NSAttributedString.Key : Any], for: .selected)
        loginSegmentedControl.tintColor = UIColor(named: "AppPrimary")
 
    
    }
    
    func setUpContainerView(){
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 2, height: 4)
    }
    
    func setUpLabels(){
        confirmPasswordLabel.isEnabled = false
    }
    
    func setUpTextFields(){
        emailTextField.autocorrectionType = .no
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .none
        
        confirmPasswordTextField.autocorrectionType = .no
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isEnabled = false
        confirmPasswordTextField.textContentType = .none
        
       // removing extra password field initially
        DispatchQueue.main.async {
            self.removePasswordField()
        }
    }
    
    func setUpButtons(){
        facebookLoginButton.layer.cornerRadius = 5
        facebookLoginButton.addShadow()
        loginButton.layer.cornerRadius = 5
        loginButton.addShadow()
    }

}
