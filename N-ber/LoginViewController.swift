//
//  ViewController.swift
//  N-ber
//
//  Created by Seyma on 15.08.2023.
//

import UIKit

class LoginViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswprdTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //MARK: - Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
    }
    
    
}

