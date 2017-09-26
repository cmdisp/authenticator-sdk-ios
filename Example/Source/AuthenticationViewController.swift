//
//  AuthenticationViewController.swift
//
//  Copyright (c) 2017 CM
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
import UserNotifications

class AuthenticationViewController: UIViewController {
    
    enum AuthenticationItem {
        case PhoneNumber
        case Date
        case IpLocation
        case TimeRemaining
        case OTP
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    
    var auth: AuthenticationRequest? {
        didSet {
            updateView()
        }
    }
    
    var items: [AuthenticationItem] = []
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()
    
    var timer: Timer?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = NSLocalizedString("Authentication request", comment: "")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Back", comment: ""),
            style: .plain,
            target: nil,
            action: nil
        )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "icon_qr"),
            style: .plain,
            target: self,
            action: #selector(scanQR)
        )
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
        loadAuthenticationRequest()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationReceived(notification:)),
            name: AppConfig.notificationNames.pushNotificationReceived,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateView() {
        tableView.isHidden = true
        approveButton.isHidden = true
        denyButton.isHidden = true
        
        guard let auth = auth else {
            timer?.invalidate()
            tableView.reloadData()
            return
        }
        
        tableView.isHidden = false
        
        items = [
            .PhoneNumber,
            .Date,
            .IpLocation,
            .TimeRemaining,
        ]
        
        if auth.authType == .otp {
            items.append(.OTP)
        } else {
            approveButton.isHidden = false
            denyButton.isHidden = false
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
    }
    
    // MARK: Authentication request
    
    func loadAuthenticationRequest() {
        guard let environmentId = appSettings.environmentId, let deviceSecret = appSettings.deviceSecret else {
            return
        }
        
        authenticator.authClient.authenticationRequest(environmentId: environmentId, deviceSecret: deviceSecret) { (authentication, error) in
            if error == nil {
                self.auth = authentication
            }
        }
    }

    func updateAuthentication(status: AuthStatus) {
        guard let auth = self.auth, let environmentId = appSettings.environmentId, let deviceSecret = appSettings.deviceSecret else {
            return
        }
        
        authenticator.authClient.updateStatus(id: auth.id, environmentId: environmentId, deviceSecret: deviceSecret, status: status) { (auth, error) in
            var message: String
            if error == nil {
                message = "Authentication: \(String(describing: status))"
                self.auth = nil
            } else {
                message = NSLocalizedString("Could not update authentication request", comment: "")
            }
            
            let alert = UIAlertController(title: message, message: "", preferredStyle: .actionSheet)
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    alert.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    // MARK: Notification observer
    
    @objc func notificationReceived(notification: Notification) {
        guard let notification = notification.userInfo?["notification"] as? UNNotificationContent else {
            return
        }
        
        if NotificationCategoryType(rawValue: notification.categoryIdentifier) == .authQr {
            self.scanQR()
        } else {
            loadAuthenticationRequest()
        }
    }
}

extension AuthenticationViewController {
    
    // MARK: Actions
    
    @objc func scanQR() {
        self.performSegue(withIdentifier: AppConfig.segues.authenticationToScanQr, sender: nil)
    }
    
    @IBAction func approveButtonClicked(_ sender: Any) {
        updateAuthentication(status: .approved)
    }
    
    @IBAction func denyButtonClicked(_ sender: Any) {
        updateAuthentication(status: .denied)
    }
}

extension AuthenticationViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Table view delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let auth = self.auth else {
            return cell
        }
        
        switch (items[indexPath.row]) {
        case .PhoneNumber:
            cell.textLabel?.text = NSLocalizedString("Phone Number", comment: "")
            cell.detailTextLabel?.text = appSettings.phoneNumber ?? ""
        case .Date:
            cell.textLabel?.text = NSLocalizedString("Date", comment: "")
            cell.detailTextLabel?.text = dateFormatter.string(from: auth.created)
        case .IpLocation:
            let ip = auth.ip ?? ""
            let location = auth.location
            
            cell.textLabel?.text = NSLocalizedString("IP & Location", comment: "")
            cell.detailTextLabel?.text = "\(ip)\n\(location)"
        case .TimeRemaining:
            cell.textLabel?.text = NSLocalizedString("Time remaining", comment: "")
            
            let timeRemaining = auth.timeRemaining
            if timeRemaining <= 0 {
                self.auth = nil
            }
            
            cell.detailTextLabel?.text = "\(Int(timeRemaining)) \(NSLocalizedString("seconds", comment: ""))"
        case .OTP:
            cell.textLabel?.text = NSLocalizedString("One Time Password", comment: "")
            cell.detailTextLabel?.text = auth.pin ?? ""
        }

        return cell
    }
}
