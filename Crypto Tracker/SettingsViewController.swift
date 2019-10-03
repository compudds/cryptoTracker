//
//  SettingsViewController.swift
//  Crypto Tracker
//
//  Created by Eric Cook on 6/17/19.
//  Copyright © 2019 Better Search, LLC. All rights reserved.
//

import UIKit

var cryptoSymbols = [String]()

private let headerHeight : CGFloat = 50.0

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    var touchToggle = UISwitch()
    var cryptoInput = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: headerHeight + 40, width: view.frame.size.width, height: headerHeight))
        headerLabel.text = "Settings"
        headerLabel.font = headerLabel.font.withSize(36)
        headerLabel.textAlignment = .center
        view.addSubview(headerLabel)
        

        let cryptoLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 120, width: 300, height: 20))
        cryptoLabel.text = "Crypto Symbols - separate by commas"
        cryptoLabel.textAlignment = .left
        view.addSubview(cryptoLabel)
        
        cryptoInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 150, width: 330, height: 40))
        cryptoInput.placeholder = "BTC,ETH,XRP..."
        cryptoInput.borderStyle = .line
        cryptoInput.keyboardType = .default
        cryptoInput.enablesReturnKeyAutomatically = true
        cryptoInput.autocapitalizationType = .allCharacters
        cryptoInput.delegate = self
        cryptoInput.addTarget(self, action: #selector(saveCryptoSymbols), for: .editingDidEnd)
        view.addSubview(cryptoInput)
        
        let touchId = UILabel(frame: CGRect(x: 20, y: headerHeight + 250, width: 160, height: 20))
        touchId.text = "Touch ID or Face ID"
        touchId.textAlignment = .left
        view.addSubview(touchId)
        
        touchToggle = UISwitch(frame: CGRect(x: 300, y: headerHeight + 250, width: 160, height: 20))
        touchToggle.addTarget(self, action: #selector(toggleTapped), for: .valueChanged)
        view.addSubview(touchToggle)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("SettingView Internet connection OK")
            
            getSavedCryptoSymbols()
            
            recallToggleSwitchSetting()
            
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
    
    func recallToggleSwitchSetting() {
        
        let faceID = UserDefaults.standard.bool(forKey: "secure")
        
        print(faceID)
        
        if faceID == true {
            
            touchToggle.setOn(true, animated: false)
            
        } else {
            
            touchToggle.setOn(false, animated: false)
            
        }
    }
    
   
    @objc func toggleTapped() {
        
        if touchToggle.isOn {
            
            touchToggle.setOn(true, animated: false)
            
            UserDefaults.standard.set(true, forKey: "secure")
            
        } else {
            
            touchToggle.setOn(false, animated: false)
            
            UserDefaults.standard.set(false, forKey: "secure")
            
        }
        
       
    }
    
    @objc func saveCryptoSymbols() {
        
        cryptoSymbols = []
        
        coins = []
        
        let symbol = cryptoInput.text!
        
        for item in symbol.components(separatedBy: ",") {
            
            cryptoSymbols.append(item)
            
            let coin = Coin(symbol: item )
            
            coins.append(coin)
            
        }
        
        UserDefaults.standard.set(cryptoSymbols, forKey: "symbols")
        
        print("cryptoSymbols: \(cryptoSymbols)")
        
    }
    
    func getSavedCryptoSymbols() {
        
        if cryptoSymbols.isEmpty {
            
            let symbols = UserDefaults.standard.array(forKey: "symbols") ?? []
            
            if symbols.isEmpty {
                
                print("CryptoSymbols and local storage are empty!")
                
            } else {
                
                for sym in symbols {
                    
                    cryptoSymbols.append(sym as! String)
                    
                }
                
                let string = cryptoSymbols.joined(separator: ",")
                
                cryptoInput.text = "\(string)"
                
                print("CryptoSymbols re-set and no longer empty!")
                
            }
            
            
            
        } else {
            
            let string = cryptoSymbols.joined(separator: ",")
            
            cryptoInput.text = "\(string)"
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        cryptoInput.resignFirstResponder()
        
        return true
    }
    
}
