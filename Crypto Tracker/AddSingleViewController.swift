//
//  AddSingleViewController.swift
//  Crypto Tracker
//
//  Created by Eric Cook on 10/29/21.
//  Copyright © 2021 Better Search, LLC. All rights reserved.
//

import UIKit

private let headerHeight : CGFloat = 25.0
var addSingleBuy = [Dictionary<String,String>()]  //[String:String]]()
var singleCell = [[String:Any]]()  //[Dictionary<String,String>()]  //[[String:String]]()

class AddSingleViewController: UIViewController, CoinDataDelegate, UITextFieldDelegate {
    
    var dateLabel = UILabel()
    var symbolLabel = UILabel()
    var sharesLabel = UILabel()
    var priceLabel = UILabel()
    var feesLabel = UILabel()
    var costLabel = UILabel()
    
    var dateInput = UITextField()
    var symbolInput = UITextField()
    var sharesInput = UITextField()
    var priceInput = UITextField()
    var feesInput = UITextField()
    var costInput = UITextField()
    var counterInput = UITextField()
    
    var addButton = UIButton()
    
    var coin : Coin?
    
    var nameFull = String()
    
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 40, width: screenWidth, height: screenHeight))

        scrollView.contentSize = CGSize(width: screenWidth, height: 1200)
        
        self.view.addSubview(scrollView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        scrollView.addGestureRecognizer(tap)
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 5, width: screenWidth, height: headerHeight))
        headerLabel.text = "Add Buys"
        headerLabel.font = headerLabel.font.withSize(26)
        headerLabel.textAlignment = .center
        scrollView.addSubview(headerLabel)
        
        counterInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 40, width: 95, height: 40))
        counterInput.placeholder = ""
        counterInput.borderStyle = .line
        counterInput.text = randomString(length: 5)
        counterInput.isUserInteractionEnabled = false
        counterInput.delegate = self
        scrollView.addSubview(counterInput)
                
        let dateLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 90, width: 300, height: 20))
        dateLabel.text = "Date "
        dateLabel.textAlignment = .left
        scrollView.addSubview(dateLabel)
        
        dateInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 120, width: 330, height: 40))
        dateInput.placeholder = "MM/DD/YYYY"
        dateInput.borderStyle = .line
        dateInput.keyboardType = .default
        dateInput.enablesReturnKeyAutomatically = true
        dateInput.delegate = self
        scrollView.addSubview(dateInput)
        
        let coinLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 180, width: 300, height: 20))
        coinLabel.text = "Coin Symbol "
        coinLabel.textAlignment = .left
        scrollView.addSubview(coinLabel)
        
        symbolInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 210, width: 330, height: 40))
        symbolInput.placeholder = "Coin Symbol"
        symbolInput.borderStyle = .line
        symbolInput.keyboardType = .default
        symbolInput.enablesReturnKeyAutomatically = true
        symbolInput.autocapitalizationType = .allCharacters
        symbolInput.delegate = self
        scrollView.addSubview(symbolInput)
        
        let sharesLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 260, width: 300, height: 20))
        sharesLabel.text = "Shares "
        sharesLabel.textAlignment = .left
        scrollView.addSubview(sharesLabel)
        
        sharesInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 290, width: 330, height: 40))
        sharesInput.placeholder = "Amount Bought "
        sharesInput.borderStyle = .line
        sharesInput.keyboardType = .decimalPad
        sharesInput.enablesReturnKeyAutomatically = true
        sharesInput.delegate = self
        scrollView.addSubview(sharesInput)
        
        let priceLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 340, width: 300, height: 20))
        priceLabel.text = "Price per Share $"
        priceLabel.textAlignment = .left
        scrollView.addSubview(priceLabel)
        
        priceInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 370, width: 330, height: 40))
        priceInput.placeholder = ""
        priceInput.borderStyle = .line
        priceInput.keyboardType = .decimalPad
        priceInput.enablesReturnKeyAutomatically = true
        priceInput.delegate = self
        scrollView.addSubview(priceInput)
        
        let feesLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 420, width: 300, height: 20))
        feesLabel.text = "Fees/Gas $"
        feesLabel.textAlignment = .left
        scrollView.addSubview(feesLabel)
        
        feesInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 450, width: 330, height: 40))
        feesInput.placeholder = ""
        feesInput.borderStyle = .line
        feesInput.keyboardType = .decimalPad
        feesInput.enablesReturnKeyAutomatically = true
        feesInput.delegate = self
        scrollView.addSubview(feesInput)
        
        let costLabel = UILabel(frame: CGRect(x: 20, y: headerHeight + 500, width: 300, height: 20))
        costLabel.text = "Cost Basis "
        costLabel.textAlignment = .left
        scrollView.addSubview(costLabel)
        
        costInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 530, width: 330, height: 40))
        costInput.placeholder = ""
        costInput.borderStyle = .line
        costInput.keyboardType = .decimalPad
        costInput.enablesReturnKeyAutomatically = true
        costInput.delegate = self
       
        scrollView.addSubview(costInput)
        
        addButton = UIButton(frame: CGRect(x: 140, y: headerHeight + 600, width: 130, height: 40))
        addButton.setTitle("Add", for: .normal)
        addButton.backgroundColor = .red
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        scrollView.addSubview(addButton)
        
        if coin != nil {
            CoinData.shared.delegate = self
            edgesForExtendedLayout = []
            view.backgroundColor = UIColor.white
            title = coinSymbol
        
        }
        
        
    }
    
    @objc func editTapped() {
        
        navigationController?.pushViewController(EditSingleViewController(), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //singleCell = []
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("AddSingleTableViewController Internet connection OK")
            
        } else {
            
            print("Internet connection FAILED")
            
            let alert = UIAlertController(title: "Sorry, no internet connection found.", message: "This app requires an internet connection.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Try Again?", style: .default, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
                self.noInternetConnection()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func removeSubview() {
        
        if let viewWithTag = self.view.viewWithTag(100) {
            
            viewWithTag.removeFromSuperview()
        
        } else {
            
            print("No!")
            
        }
    }
            
    @objc func addButtonTapped(sender: UIButton!) {
        
        if counterInput.text! == "" || symbolInput.text! == "" || dateInput.text! == "" || priceInput.text! == "" || sharesInput.text! == "" || feesInput.text! == "" || costInput.text! == "" {
            
            let alert = UIAlertController(title: "All fields must be filled in!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
             
             alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                 
                 alert.dismiss(animated: true, completion: nil)
                 
                 
             }))
             
             self.present(alert, animated: true, completion: nil)
            
        } else {
            
            cellId = ""
            
            singleCell.removeAll()
            
            let storedItems = UserDefaults.standard.object(forKey: symbolInput.text! + "buy") as? [[String:String]]   //[Dictionary<String, String>]?
            
            //singleCell.updateValue(storedItems, forKey: symbolInput.text! + "buy")
            
            if (storedItems != nil) {
                
                for item in storedItems! {
                    
                    singleCell.append(item)
                    
                }
                
            } else {
                
            }
            
            /*if let count = storedItems??.count {
                
                for i in 0..<count {
                    
                    singleCell.append(storedItems!![i])
                }
                
            }*/
            
            let populateCell: [String:String] = ["id": symbolInput.text!,"idCode": counterInput.text!,
                "dataCell": "ID: \(counterInput.text!)\rDate: \(dateInput.text!)\rSymbol: \(symbolInput.text!)\rShares: \(sharesInput.text!)\rPrice: $\(priceInput.text!)\rGas/Fees: $\(feesInput.text!)\rCost Basis: $\(costInput.text!)","idCounter": counterInput.text!,"date": dateInput.text!,"symbol": symbolInput.text!,"shares": sharesInput.text!,"price": priceInput.text!,"gas": feesInput.text!,"costBasis": costInput.text!]
            
            cellId = counterInput.text!
            
            //singleCell.updateValue(populateCell, forKey: symbolInput.text! + "buy")
            
            singleCell.append(populateCell)
            
            UserDefaults.standard.set(singleCell, forKey: symbolInput.text! + "buy")
            
            UserDefaults.standard.set(singleCell, forKey: symbolInput.text! + counterInput.text!)
            
            let id = counterInput.text!
            
            UserDefaults.standard.set(id, forKey: symbolInput.text! + "id")
            
            let price = Double(priceInput.text!)
            UserDefaults.standard.set(price, forKey: symbolInput.text! + "price")
            
            let shares = Double(sharesInput.text!)
            UserDefaults.standard.set(shares, forKey: symbolInput.text! + "amount")
            
            let costBasis = Double(costInput.text!)
            UserDefaults.standard.set(costBasis, forKey: symbolInput.text! + "costBasis")
            
            let gas = Double(feesInput.text!)
            UserDefaults.standard.set(gas, forKey: symbolInput.text! + "gas")
            
            let invAmt = Double(costInput.text!)
            UserDefaults.standard.set(invAmt,forKey: symbolInput.text! + "investmentAmt")
            
            //TOTALS
            
            let array = UserDefaults.standard.object(forKey: symbolInput.text! + "totalPrice") as? [Any]
            
            if (array == nil) {
                
                UserDefaults.standard.set([Double(priceInput.text!)], forKey: symbolInput.text! + "totalPrice")
                
            } else {
                
                var newArray = [Any]()
                
                //var newArray1 = [Any]()
                
                if array != nil {
                    
                    for amt in array ?? [] {
                        
                        newArray.append(amt)
                        
                    }
                    
                    let totalPrice = Double(priceInput.text!)
                    
                    newArray.append(totalPrice!)
                    
                    UserDefaults.standard.set(newArray, forKey: symbolInput.text! + "totalPrice")
                    
                } else {
                    
                    print("array is nil.")
                }
                
            }
            
            
            
            let array1 = UserDefaults.standard.object(forKey: symbolInput.text! + "totalCostBasis") as? [Any]
            
            if (array1 == nil) {
                
                UserDefaults.standard.set([Double(costInput.text!)], forKey: symbolInput.text! + "totalCostBasis")
                
            } else {
                
                var newArray1 = [Any]()
                
                if array1 != nil {
                    
                    for amt in array1 ?? [] {
                        
                        newArray1.append(amt)
                       
                    }
                    
                    let totalCostBasis = Double(costInput.text!)
                    
                    newArray1.append(totalCostBasis!)
                    
                    UserDefaults.standard.set(newArray1, forKey: symbolInput.text! + "totalCostBasis")
                }
                
                
            }
            
            
            
            let array2 = UserDefaults.standard.object(forKey: symbolInput.text! + "totalAmount") as? [Any]
            
            if (array2 == nil) {
                
                UserDefaults.standard.set([Double(sharesInput.text!)], forKey: symbolInput.text! + "totalAmount")
                
            } else {
                
                var newArray2 = [Any]()
                
                if array2 != nil {
                    
                    for amt in array2 ?? [] {
                        
                        newArray2.append(amt)
                        
                    }
                    
                    let totalShares = Double(sharesInput.text!)
                    
                    newArray2.append(totalShares!)
                     
                    UserDefaults.standard.set(newArray2, forKey: symbolInput.text! + "totalAmount")
                    
                }
                
                
                
            }
            
            let array3 = UserDefaults.standard.object(forKey: symbolInput.text! + "totalGas") as? [Any]
                
            if (array3 == nil) {
                
                UserDefaults.standard.set([Double(feesInput.text!)], forKey: symbolInput.text! + "totalGas")
                
            } else {
                
                var newArray3 = [Any]()
                
                if array3 != nil {
                    
                    for amt in array3 ?? [] {
                        
                        newArray3.append(amt)
                        
                    }
                    
                    let totalGas = Double(feesInput.text!)
                    
                    newArray3.append(totalGas!)
                    
                    UserDefaults.standard.set(newArray3, forKey: symbolInput.text! + "totalGas")
                    
                }
                
                
                
            }
            
            let array4 = UserDefaults.standard.object(forKey: symbolInput.text! + "totalInvestmentAmt") as? [Any]
            
            if (array4 == nil) {
                
                UserDefaults.standard.set([costInput.text!],forKey: symbolInput.text! + "totalInvestmentAmt")
                
            } else {
                
                var newArray4 = [Any]()
                
                if array4 != nil {
                    
                    for amt in array4 ?? [] {
                        
                        newArray4.append(amt)
                        
                    }
                    
                    let totalInvAmt = Double(costInput.text!)
                    
                    newArray4.append(totalInvAmt!)
                    
                    UserDefaults.standard.set(newArray4,forKey: symbolInput.text! + "totalInvestmentAmt")
                    
                }
               
                    
            }
           
           let alert = UIAlertController(title: "Buy added!", message: "You have sucessfully added a buy.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                
                self.clearInputFields()
                
                /*let tableVC = CryptoTableViewController()
                tableVC.isModalInPresentation = true
                
                let navController = UINavigationController(rootViewController: tableVC)
                self.present(navController, animated: true, completion: nil)*/
                
                alert.dismiss(animated: true, completion: nil)
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    func clearInputFields() {
        
        dateInput.text = ""
        sharesInput.text = ""
        counterInput.text = randomString(length: 5)
        priceInput.text = ""
        feesInput.text = ""
        symbolInput.text = ""
        costInput.text = ""
        
        
    }
    
    func doubleToMoneyString(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR"
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}
