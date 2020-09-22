//
//  SignInVC.swift
//  SchoolLift
//
//  Created by Dylan Dakil on 4/21/18.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {

    private static let _instance = SignInVC()
    
    static var Instance: SignInVC {
        return _instance
    }
    
    private let REQUEST_SEGUE = "RequestVC"
    
    @IBOutlet var Emailtextfield: UITextField!
    
    @IBOutlet var Passwordtextfield: UITextField!
    
    @IBAction func Login(_ sender: Any) {
        if Emailtextfield.text != "" && Passwordtextfield.text != "" {
            AuthProvider.Instance.login(withEmail: Emailtextfield.text!, password: Passwordtextfield.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem With Authentication", message: message!)
                } else {
                    
                    if let user = Auth.auth().currentUser {
                    //checks if user is verified and adds alert if not
                        if !user.isEmailVerified{
                        
                            let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email?", preferredStyle: .alert)
                            let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                                (_) in
                                user.sendEmailVerification(completion: nil)
                            }
                            let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                            
                            alertVC.addAction(alertActionOkay)
                            alertVC.addAction(alertActionCancel)
                            self.present(alertVC, animated: true, completion: nil)
     
                        } else {
                            
                            RideHandler.Instance.rider = self.Emailtextfield.text!
                            self.Emailtextfield.text = ""
                            self.Passwordtextfield.text = ""
                            self.performSegue(withIdentifier: self.REQUEST_SEGUE, sender: nil)
                        }
                    }
                }
                
            })
        } else {
            alertTheUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields")
        }
    }
    @IBAction func SignUp(_ sender: Any) {
        
        if Emailtextfield.text! != "" && Passwordtextfield.text != ""
        {
            let customDomain = "gmail" //change back to "txstate"
            let test = Emailtextfield.text!
            
            if isValidEmail(testEmail: test, domain: customDomain) == true {
                //Test succeedes... Here you would register the users as normal
                            AuthProvider.Instance.signUp(withEmail: Emailtextfield.text! , password: Passwordtextfield.text! , loginHandler: {(message) in
                                if message != nil {
                                    self.alertTheUser(title: "Problem With Creating A New User", message: message!)
                
                                } else {
                                    self.sendVerificationMail()
                                    self.alertTheUser(title: "Verification email has been sent", message: "Please go to your email to verify your account")

                                 //   self.performSegue(withIdentifier: self.REQUEST_SEGUE, sender: nil)
                                }
                            })
                print("register \(test)")

            }else{
                //Test fails... Here you might tell the user that their email doesn't check out
                alertTheUser(title: "Problem With Creating A New User", message: "Has to be a txstate.edu email")
            }
        }
    }

    
    private var authUser : User? {
        return Auth.auth().currentUser
    }
    
    public func sendVerificationMail() {
        if self.authUser != nil && !self.authUser!.isEmailVerified {
            self.authUser!.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
                print(error as Any)
                print("couldnt send verification email")
            })
        }
        else {
            // Either the user is not available, or the user is already verified.
        }
    }

    // This function compares email string to match txstate.edu requirement to sign up
    func isValidEmail(testEmail:String, domain:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[\(domain)]+\\.[com]{3,\(domain.count)}"//change back to "edu"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testEmail)
        return result
        
    }
    
    
    //This is a basic alert the user function
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true,completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Texas State 02")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)

        // Do any additional setup after loading the view.
    }


}
