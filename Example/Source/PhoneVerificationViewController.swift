//
//  PhoneVerificationViewController.swift
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

class PhoneVerificationViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK:  - View lifecycle
    
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
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        guard let phoneNumber = self.phoneNumberTextField.text, isValidPhoneNumber(number: phoneNumber) else {
            let alert = UIAlertController(
                title: NSLocalizedString("Invalid phone number", comment: ""),
                message: NSLocalizedString("The phone number is invalid", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.nextButton.isEnabled = false

        authenticator.deviceClient.register(phoneNumber: phoneNumber) { (registration, error) in
            self.nextButton.isEnabled = true
            
            switch (registration?.registrationStatus ?? .unverified) {
            case .pending:
                appSettings.phoneNumber = phoneNumber
                self.performSegue(withIdentifier: AppConfig.segues.phoneToPinVerification, sender: nil)
            case .verified:
                appSettings.phoneNumber = phoneNumber
                appSettings.isVerified = true
                self.performSegue(withIdentifier: AppConfig.segues.phoneToAuthentication, sender: nil)
            default:
                let alert = UIAlertController(
                    title: NSLocalizedString("Error", comment: ""),
                    message: NSLocalizedString("Could not request phone number verification. Please try again", comment: ""),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Validation
    
    func isValidPhoneNumber(number: String) -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: number, options: [], range: NSMakeRange(0, number.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == number.characters.count
            }
        } catch {
        }
        return false
    }
}

extension PhoneVerificationViewController: UITextFieldDelegate {
    
    // MARK: - UITextField delegates
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.isEmpty {
            textField.text = "+"
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength >= 1
    }
}
