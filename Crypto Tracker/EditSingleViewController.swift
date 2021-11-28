//
//  EditSingleViewController.swift
//  Crypto Tracker
//
//  Created by Eric Cook on 10/30/21.
//  Copyright © 2021 Better Search, LLC. All rights reserved.
//

import UIKit

private let headerHeight : CGFloat = 25.0

var editSingleCellId = [String]()
var editSingleCellBuy = [[String:String]]()
var editDateInput = String()
var editCoinInput = String()
var editSharesInput = String()
var editPriceInput = String()
var editFeesInput = String()
var editCostInput = String()
var editCounterInput = String()
var editSingleCell = [Dictionary<String,String>()]
var editSingleCell2 = [Dictionary<String,String>()]

class EditSingleViewController: UIViewController, CoinDataDelegate, UITextFieldDelegate {
    
    var dateLabel = UILabel()
    var coinLabel = UILabel()
    var sharesLabel = UILabel()
    var priceLabel = UILabel()
    var feesLabel = UILabel()
    var costLabel = UILabel()
    
    var dateInput = UITextField()
    var coinInput = UITextField()
    var sharesInput = UITextField()
    var priceInput = UITextField()
    var feesInput = UITextField()
    var costInput = UITextField()
    var counterInput = UITextField()
    
    var editButton = UIButton()
    
    var coin : Coin?
    
    var nameFull = String()
    
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: screenHeight))

        scrollView.contentSize = CGSize(width: screenWidth, height: 1200)
        // add the scroll view to self.view
        self.view.addSubview(scrollView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        scrollView.addGestureRecognizer(tap)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeTapped))
        
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 5, width: screenWidth, height: headerHeight))
        headerLabel.text = "Edit Buy"
        headerLabel.font = headerLabel.font.withSize(26)
        headerLabel.textAlignment = .center
        scrollView.addSubview(headerLabel)
        
        counterInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 40, width: 65, height: 40))
        counterInput.placeholder = ""
        counterInput.borderStyle = .line
        counterInput.text = ""  //randomString(length: 5)
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
        
        coinInput = UITextField(frame: CGRect(x: 20, y: headerHeight + 210, width: 330, height: 40))
        coinInput.placeholder = "Coin Symbol"
        coinInput.borderStyle = .line
        coinInput.keyboardType = .default
        coinInput.enablesReturnKeyAutomatically = true
        coinInput.autocapitalizationType = .allCharacters
        coinInput.delegate = self
        scrollView.addSubview(coinInput)
        
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
        
        editButton = UIButton(frame: CGRect(x: 140, y: headerHeight + 600, width: 130, height: 40))
        editButton.setTitle("Edit", for: .normal)
        editButton.backgroundColor = .red
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        scrollView.addSubview(editButton)
        
        if coin != nil {
            CoinData.shared.delegate = self
            edgesForExtendedLayout = []
            view.backgroundColor = UIColor.white
            title = coinSymbol
        
        }
        
        getBuy()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("EditSingleView Internet connection OK")
            
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
    
    func getBuy() {
        
        dateInput.text = editDateInput
        sharesInput.text = editSharesInput
        counterInput.text = editCounterInput
        priceInput.text = editPriceInput
        feesInput.text = editFeesInput
        coinInput.text = editCoinInput
        costInput.text = editCostInput
        
        coinSymbol = coinInput.text!

    }
    
    func updateTotals() {
        
        let array = UserDefaults.standard.object(forKey: coinSymbol + "totalPrice")
        
        UserDefaults.standard.removeObject(forKey: coinSymbol + "totalPrice")
        
        var newArray = [Any]()
        
        newArray.append(array!)
        
        let totalPrice = Double(priceInput.text!)
        
        newArray.append(totalPrice!)
        
        UserDefaults.standard.set(newArray, forKey: coinSymbol + "totalPrice")
        
        
        let array1 = UserDefaults.standard.object(forKey: coinSymbol + "totalCostBasis")
        
        UserDefaults.standard.removeObject(forKey: coinSymbol + "totalCostBasis")
        
        var newArray1 = [Any]()
        
        newArray1.append(array1!)
        
        let totalCostBasis = Double(costInput.text!)
        
        newArray1.append(totalCostBasis!)
        
        UserDefaults.standard.set(newArray1, forKey: coinSymbol + "totalCostBasis")
        
        
        let array2 = UserDefaults.standard.object(forKey: coinSymbol + "totalAmount")
        
        UserDefaults.standard.removeObject(forKey: coinSymbol + "totalAmount")
        
        var newArray2 = [Any]()
        
        newArray2.append(array2!)
        
        let totalShares = Double(sharesInput.text!)
        
        newArray2.append(totalShares!)
         
        UserDefaults.standard.set(newArray2, forKey: coinSymbol + "totalAmount")
        
        
        let array3 = UserDefaults.standard.object(forKey: coinSymbol + "totalGas")
        
        UserDefaults.standard.removeObject(forKey: coinSymbol + "totalGas")
        var newArray3 = [Any]()
        
        newArray3.append(array3!)
        
        let totalGas = Double(feesInput.text!)
        
        newArray3.append(totalGas!)
        
        UserDefaults.standard.set(newArray3, forKey: coinSymbol + "totalGas")
        
        
        let array4 = UserDefaults.standard.object(forKey: coinSymbol + "totalInvestmentAmt")
        
        UserDefaults.standard.removeObject(forKey: coinSymbol + "totalInvestmentAmt")
        
        var newArray4 = [Any]()
        
        newArray4.append(array4!)
        
        let totalInvAmt = Double(costInput.text!)
        
        newArray4.append(totalInvAmt!)
        
        UserDefaults.standard.set(newArray4,forKey: coinSymbol + "totalInvestmentAmt")
       
    }
    
    func updateUserDefaults() {
        
        editSingleCell.removeAll()
        
        editSingleCell2.removeAll()
        
        let storedItems = UserDefaults.standard.object(forKey: coinSymbol + "buy") as? [Dictionary<String, String>]?
        
        if let count = storedItems??.count {
            
            for i in 0..<count {
                
                //editSingleCell2.append(storedItems!![i])
                
                let id = storedItems!![i]["idCode"] ?? ""
                
                print("id: \(id)")
                
                if id == counterInput.text! {
                    
                    editSingleCell2.append(storedItems!![i])
                
                    for i in 0..<editSingleCell2.count {
                
                        let getBuy = UserDefaults.standard.object(forKey: coinSymbol + id) as? [Dictionary<String, String>]?
                        
                        print("getBuy: \(String(describing: getBuy))")
                
                        if getBuy!![i]["idCode"] != "" {
                
                            let populate: [String:String] = ["id": coinInput.text!,"idCode": counterInput.text!,
                             "dataCell": "ID: \(counterInput.text!)\rDate: \(dateInput.text!)\rSymbol: \(coinInput.text!)\rShares: \(sharesInput.text!)\rPrice: $\(priceInput.text!)\rGas/Fees: $\(feesInput.text!)\rCost Basis: $\(costInput.text!)", "idCounter": counterInput.text!,"date": dateInput.text!,"symbol": coinInput.text!,"shares": sharesInput.text!,"price": priceInput.text!,"gas": feesInput.text!,"costBasis": costInput.text!]
                
                            UserDefaults.standard.removeObject(forKey: coinSymbol + "buy")
                            
                            editSingleCell.append(populate)
                
                            UserDefaults.standard.set(editSingleCell, forKey: coinSymbol + "buy")
                            
                            let storedEdit = UserDefaults.standard.object(forKey: coinSymbol + "buy") as? [Dictionary<String, String>]?
                
                            print("storedEdit: \(String(describing: storedEdit))")
                
                        } else {
                
                            print("getBuy is empty!!!")
                 
                        }
                 
                    }
                 
                } else {
                    
                    editSingleCell.append(storedItems!![i])
                    
                }
                
            }
                
        }
        
        UserDefaults.standard.set(editSingleCell, forKey: coinSymbol + "buy")
        
        let storedItems2 = UserDefaults.standard.object(forKey: coinSymbol + "buy") as? [Dictionary<String, String>]?
        
        print("userDefaults updated!\rstoredItems2: \(String(describing: storedItems2))")
        
    }
    
    @objc func editButtonTapped(sender: UIButton!) {
        
        if editDateInput == dateInput.text! && editCounterInput == counterInput.text! && editCoinInput == coinInput.text! && editFeesInput == feesInput.text! && editPriceInput == priceInput.text! && editSharesInput == sharesInput.text! && editCostInput == costInput.text! {
            
            let alert = UIAlertController(title: "No changes were made!", message: "Please try again.", preferredStyle: UIAlertController.Style.alert)
             
             alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                 
                 alert.dismiss(animated: true, completion: nil)
                 
             }))
             
             self.present(alert, animated: true, completion: nil)
            
        } else {
            
            singleCell.removeAll()
            
            coinSymbol = coinInput.text!
            
            /*let storedItems = UserDefaults.standard.object(forKey: coinSymbol + counterInput.text!) as? [[String:String]]  //[Dictionary<String, String>]?
            
            if (storedItems != nil) {
                
                for item in storedItems! {
                    
                    singleCell.append(item)
                      
                }
                
            } else {
                
            }*/
            
            /*if let count = storedItems.count {
                
                for i in 0..<count {
                    
                    singleCell.updateValue(storedItems, forKey: coinSymbol + counterInput.text!)
                    
                    singleCell.append(storedItems!![i])
                }
                
            }*/
            
            let populateCell: [String:String] = ["id": coinInput.text!,"idCode": counterInput.text!,
                "dataCell": "ID: \(counterInput.text!)\rDate: \(dateInput.text!)\rSymbol: \(coinInput.text!)\rShares: \(sharesInput.text!)\rPrice: $\(priceInput.text!)\rGas/Fees: $\(feesInput.text!)\rCost Basis: $\(costInput.text!)", "idCounter": counterInput.text!,"date": dateInput.text!,"symbol": coinInput.text!,"shares": sharesInput.text!,"price": priceInput.text!,"gas": feesInput.text!,"costBasis": costInput.text!]
            
            singleCell.append(populateCell)
            
            UserDefaults.standard.set(singleCell, forKey: coinSymbol + counterInput.text!)
            
            updateUserDefaults()
            
            //updateTotals()
            
            print("Edit updated!")
            
            clearInputFields()

           let alert = UIAlertController(title: "Update Complete", message: "You have sucessfully updated this buy.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
           
        }
        
       
        
    }
    
    func clearInputFields() {
        
        dateInput.text = ""
        sharesInput.text = ""
        counterInput.text = ""
        priceInput.text = ""
        feesInput.text = ""
        coinInput.text = ""
        costInput.text = ""
        editCounterInput = ""
        editCostInput = ""
        editCoinInput = ""
        editFeesInput = ""
        editSharesInput = ""
        editPriceInput = ""
        editDateInput = ""
        
    }
    
    @objc func homeTapped() {
        
        navigationController?.pushViewController(CryptoTableViewController(), animated: true)
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
