//
//  ViewController.swift
//  N-ber
//
//  Created by Seyma on 15.08.2023.
//  11

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    var isLogin = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroungTap()
        
    }

    //MARK: - Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("Bütün alanları doldurun.")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            print("şifremi unuttum için veriler")
        } else {
            ProgressHUD.showFailed("Bütün alanları doldurun.")
        }
        
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            print("şifre gönder için veriler")
        } else {
            ProgressHUD.showFailed("Bütün alanları doldurun.")
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Giriş")
        isLogin.toggle()
        resendEmailButtonOutlet.isHidden = true
    }
    
    //MARK: - Setup
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)) , for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)) , for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)) , for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func setupBackgroungTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
    //MARK: - Animations
    
    private func updateUIFor(login: Bool) {
        loginButtonOutlet.setTitle(login ? "Giriş" : "Kayıt" , for: .normal)
        signUpButtonOutlet.setTitle(login ? "Kayıt Ol" : "Giriş", for: .normal)
        signUpLabel.text = login ? "Hesabım Yok?" : "Hesabım Var"
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordLineView.isHidden = login
            self.resendEmailButtonOutlet.isHidden = login
        }
    }
    
    private func updatePlaceholderLabels(textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Şifre" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Şifre (Tekrar)" : ""
        }
    }
    
    
    //MARK: - Helpers
    private func isDataInputedFor(type: String)  -> Bool {
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""  // resend mail button is default
        }
    }
    
    private func loginUser() {
        
    }
    
    private func registerUser() {
        if passwordTextField.text! == repeatPasswordTextField.text! {
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                if error == nil {
                    ProgressHUD.showSuccess("Emailinize doğrulama postası gönderildi.")
                    self.resendEmailButtonOutlet.isHidden = false
                } else {
                    ProgressHUD.showFailed(error?.localizedDescription)
                    self.resendEmailButtonOutlet.isHidden = true
                }
            }
        } else {
            ProgressHUD.showFailed("Girdiğiniz şifreler birbirinden farklı.")
            self.resendEmailButtonOutlet.isHidden = true
        }
    }
    
    
}

