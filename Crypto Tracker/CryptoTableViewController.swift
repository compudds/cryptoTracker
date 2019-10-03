//
//  CryptoTableViewController.swift
//  Crypto Tracker
//
//  Created by Better Search, LLC on 4/30/18.
//  Copyright © 2019 Eric Cook. All rights reserved.
//

import UIKit
import LocalAuthentication
import Alamofire

private let headerHeight : CGFloat = 100.0
private let netWorthHeight : CGFloat = 45.0
var namesData = [String]()
var namesDataDic = [String:String]()
var percentDic = [String:String]()
var percentData = [String]()
//var yesterdaysClose = Double()
var yesterdayData = [String]()
var yesterdayDic = [String:String]()

class CryptoTableViewController: UITableViewController, CoinDataDelegate {
    
    var amountLabel = UILabel()
    
    var coin : Coin?
    
    var timer = Timer()
    
    var count = 0
    
    var count1 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSpinnerView()
        
        getSavedCryptoSymbols()
        
        print("cryptoSymbols: \(cryptoSymbols)")
        
        let editButton   = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(moveRows))
        
        let reportButton = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportTapped))
        
        navigationItem.leftBarButtonItems = [editButton, reportButton]
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            updateSecureButton()
        }
    }
    
    @objc func moveRows() {
        
        self.tableView.isEditing = true
        
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(stopMoveRows)), animated: true)
        
        timer.invalidate()
    }
    
    @objc func stopMoveRows() {
        
        self.tableView.isEditing = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(moveRows))
        
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updatePrices), userInfo: nil, repeats: true)
        
        
    }
    
    func presentAuth() {
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && UserDefaults.standard.bool(forKey: "secure") {
            
                DispatchQueue.main.async {
                    
                    let authVC = AuthViewController()
                    
                    self.present(authVC, animated: true, completion: nil)
                    
            }
                    
            
        } else {
            
            self.presentAuth()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("TableView Internet connection OK")
            
            timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updatePrices), userInfo: nil, repeats: true)
            
            print("Prices updated.")
            
            print("cryptoSymbols: \(cryptoSymbols)")
            
            CoinData.shared.getPrices()
            
            CoinData.shared.getYesterdaysClose()
            
            CoinData.shared.getClose()
            
            getFullName()
            
            retrieveFullName()
            
            percentChange24Hr()
            
            CoinData.shared.getPercents()
            
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
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        // wait five seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
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
                
                print("CryptoSymbols re-set and no longer empty!")
                
            }
            
        }
        
    }
    
    func getFullName() {
        
        namesData.removeAll()
        
        namesDataDic.removeAll()
        
        if cryptoSymbols.isEmpty {
            
            getSavedCryptoSymbols()
            
            print("CryptoSymbols and local storage are empty!")
            
        } else {
            
        for symbol in cryptoSymbols {
            
                do {
                    if let url = URL(string: "https://min-api.cryptocompare.com/data/coin/generalinfo?fsyms=\(symbol)&tsym=USD") {
                        
                        let data = try Data(contentsOf: url)
                        
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        if let object = json as? [String: Any] {
                            
                            if let data1 = object["Data"] as? [[String: Any]] {
                                
                                if let coin = data1[0]["CoinInfo"] as? [String: Any] {
                                    
                                    if var name = coin["FullName"] as? String {
                                        
                                        if name == "XRP" {
                                            
                                            name = "Ripple"
                                        }
                                        
                                        namesData.append(name)
                                        
                                        UserDefaults.standard.set(name, forKey: symbol + "name")
                                        
                                        let newValue = namesDataDic.updateValue(name, forKey: symbol)
                                        
                                        UserDefaults.standard.set(newValue, forKey: "nameDic")
                                        
                                    }
                                }
                            }
                            
                        } else {
                            print("JSON is invalid")
                        }
                    } else {
                        print("Invalid URL")
                    }
                } catch {
                    print(error.localizedDescription)
                }

            }
            
            CoinData.shared.delegate?.newName?()
        }
        
        print("namesData: \(namesData)")
    
    }
    
    func retrieveFullName() {
        
        for symbol in cryptoSymbols {
            
            if let names = UserDefaults.standard.dictionary(forKey: "nameDic") {
                
                for name in names {
                    
                    if name.key == symbol {
                        
                        namesData.append(name.value as! String)
                        
                        //print("Symbol: \(name.key) Coin Name: \(name.value)")
                       
                    }
                    
                }
            }
           
        }
        
        print("namesData: \(namesData)")
        
        print("namesDataDic: \(namesDataDic)")
    }
    
    func percentChange24Hr() {
        
        percentData.removeAll()
        
        percentDic.removeAll()
        
        if cryptoSymbols.isEmpty {
            
            getSavedCryptoSymbols()
            
            print("CryptoSymbols and local storage are empty!")
            
        } else {
        
        for symbol in cryptoSymbols {
            
            do {
                if let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(symbol)&tsyms=USD") {
                    
                    let data = try Data(contentsOf: url)
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let object = json as? [String: Any] {
                        
                        if let data1 = object["RAW"] as? [String: Any] {
                            
                            if let coin1 = data1["\(symbol)"] as? [String: Any] {
                                
                                if let usd = coin1["USD"] as? [String: Any] {
                                   
                                    if let name1 = usd["CHANGEPCT24HOUR"] as? Double {
                                        
                                        let name = String(format: "%.2f", name1)
                                        
                                        //percentData.append(name)
                                        
                                        //UserDefaults.standard.set(name, forKey: symbol + "percent")
                                        
                                        let newValue = percentDic.updateValue(name, forKey: symbol)
                                        
                                        UserDefaults.standard.set(newValue, forKey: "percentDic")
                                        
                                    }
                                }
                            }
                        }
                        
                    } else {
                        
                        print("JSON is invalid")
                    }
                } else {
                    
                    print("no URL")
                }
            } catch {
                
                print(error.localizedDescription)
            }
            
        }
            
            CoinData.shared.delegate?.newPercent?()
            
      }
        
    }
    
    @objc func updatePrices() {
        
        createSpinnerView()
        
        CoinData.shared.getPrices()
        
        percentChange24Hr()
        
        CoinData.shared.getPercents()
        
        displayNetWorth()
        
        tableView.reloadData()
        
    }

    
    @objc func reportTapped() {
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinData.shared.html())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
    }
    
    func updateSecureButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))

    }
    
    @objc func settingsTapped() {
        
        let settings = SettingsViewController()
        navigationController?.pushViewController(settings, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self
        tableView.reloadData()
        displayNetWorth()
    }
    
    func newPrices() {
        displayNetWorth()
        tableView.reloadData()
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight))
        headerView.backgroundColor = UIColor.white
        let networthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHeight))
        networthLabel.text = "Crypto Net Worth"
        networthLabel.textAlignment = .center
        
        headerView.addSubview(networthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHeight, width: view.frame.size.width, height: headerHeight - netWorthHeight)
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 60.0)
        headerView.addSubview(amountLabel)
        
        displayNetWorth()
        
        return headerView
    }
    
    func displayNetWorth() {
        amountLabel.text = CoinData.shared.netWorthAsString()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count  //CoinData.shared.coins.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 88
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel!.numberOfLines = 4
        
        cell.textLabel!.lineBreakMode = .byWordWrapping
        
        let coin = coins[indexPath.row]  //CoinData.shared.coins[indexPath.row]
        
        let name = String(format: "%.2f", coin.price)
        
        if name > coin.yesterdayClose {
            
            //print("Now: $\(name) Close: $\(coin.yesterdayClose)")
            
            //cell.backgroundColor = UIColor.green
            
            cell.textLabel?.textColor = UIColor(red: 0/255, green: 170/255, blue: 14/255, alpha: 1.0)
            
            if coin.amount != 0.0 {
                
                cell.textLabel?.text = "\(coin.name) - \(coin.symbol)\r\(coin.priceAsString())  \(coin.percentChange)%\rShares: \(coin.amount)"
                
            } else {
                
                cell.textLabel?.text = "\(coin.name) - \(coin.symbol)\r\(coin.priceAsString())  \(coin.percentChange)%"
                
            }
            
        }
            
        if name < coin.yesterdayClose {
            
            cell.textLabel?.textColor = UIColor.red
            
            
            if coin.amount != 0.0 {
                
                cell.textLabel?.text = "\(coin.name) - \(coin.symbol)\r\(coin.priceAsString())  \(coin.percentChange)%\rShares: \(coin.amount)"
                
            } else {
                
                cell.textLabel?.text = "\(coin.name) - \(coin.symbol)\r\(coin.priceAsString())  \(coin.percentChange)%"
                
            }
            
        }
            
        if name == coin.yesterdayClose {
            
            cell.textLabel?.textColor = UIColor.black
            
            
            if coin.amount != 0.0 {
                
                cell.textLabel?.text = "\(coin.name) - \(coin.symbol)\r\(coin.priceAsString())  \(coin.percentChange)%\rShares: \(coin.amount)"
                
            } else {
                
                cell.textLabel?.text = "\(coin.name) - \(coin.symbol)\r\(coin.priceAsString())  \(coin.percentChange)%"
                
            }
            
        }
            
        cell.imageView?.image = coin.image

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = coins[indexPath.row]  //CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = cryptoSymbols[sourceIndexPath.row]
        cryptoSymbols.remove(at: sourceIndexPath.row)
        cryptoSymbols.insert(movedObject, at: destinationIndexPath.row)
        
        let newCryptoSymbols = cryptoSymbols
        
        cryptoSymbols.removeAll()
        
        for sym in newCryptoSymbols {
            
            cryptoSymbols.append(sym)
        }
        
        UserDefaults.standard.set(cryptoSymbols, forKey: "symbols")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            cryptoSymbols.remove(at: indexPath.row)
            
            coins.remove(at: indexPath.row)
            
            print("Item deleted!")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.reloadData()
        
        }
    }

}

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
