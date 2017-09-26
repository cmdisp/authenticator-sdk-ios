//
//  PinVerificationViewController.swift
//
//  Copyright (c) 2017 CM Telecom B.V.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import AuthenticatorSDK

class PinVerificationViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("Registration", comment: "")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Back", comment: ""),
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    // MARK: - User actions
    
    @IBAction func verifyButtonClicked(_ sender: Any) {
        guard let pin = self.pinTextField.text else {
            return
        }
        
        self.verifyButton.isEnabled = false
        
        authenticator.deviceClient.register(verificationCode: pin) { (registration, error) in
            self.verifyButton.isEnabled = true
            
            guard let registration = registration, error == nil else {
                let alert = UIAlertController(
                    title: NSLocalizedString("Error", comment: ""),
                    message: NSLocalizedString("Could not verify the code. Please try again", comment: ""),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            switch (registration.registrationStatus) {
            case .verified:
                appSettings.isVerified = true
                self.performSegue(withIdentifier: AppConfig.segues.pinToAuthentication, sender: nil)
            default:
                let alert = UIAlertController(
                    title: NSLocalizedString("Invalid code", comment: ""),
                    message: NSLocalizedString("Invalid pin code. Please try again", comment: ""),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
