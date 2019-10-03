//
//  AuthViewController.swift
//  Crypto Tracker
//
//  Created by Better Search, LLC on 5/5/18.
//  Copyright © 2019 Eric Cook. All rights reserved.
///

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("AuthView Internet connection OK")
            
            presentAuth()
            
        } else {
            
            print("Internet connection FAILED")
            
            let alert = UIAlertController(title: "Sorry, no internet connection found.", message: "Thia app requires an internet connection.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Try Again?", style: .default, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
                self.noInternetConnection()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }

    
    func presentAuth() {
        
         //view.backgroundColor = UIColor.black
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Your crypto is proctected by biometrics") { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let cryptoTableVC = CryptoTableViewController()
                    let navController = UINavigationController(rootViewController: cryptoTableVC)
                    self.present(navController, animated: true, completion: nil)
                }
            } else {
                self.presentAuth()
            }
        }
    }
    
}
