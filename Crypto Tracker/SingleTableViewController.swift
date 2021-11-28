//
//  SingleTableViewController.swift
//  Crypto Tracker
//
//  Created by Eric Cook on 10/29/21.
//  Copyright © 2021 Better Search, LLC. All rights reserved.
//

import UIKit


private let headerHeight : CGFloat = 150.0
private let netWorthHeight : CGFloat = 45.0

var dateInputEdit = String()
var coinInputEdit = String()
var sharesInputEdit = String()
var priceInputEdit = String()
var feesInputEdit = String()
var costInputEdit = String()
var counterInputEdit = String()
var singleCellBuy = [String]()
var singleCellId = [String]()
var cellId = String()

//var storedItems = UserDefaults.standard.object(forKey: coinSymbol + "buy") as? [Dictionary<String, String>]?

//var storedFullBuy = UserDefaults.standard.object(forKey: coinSymbol + cellId) as? [Dictionary<String, String>]?

//var storedEdits = UserDefaults.standard.object(forKey: coinSymbol + "editBuy") as? [Dictionary<String, String>]?

class SingleTableViewController: UITableViewController, CoinDataDelegate {
    
    var amountLabel = UILabel()
    
    var profitOrLossLabel = UILabel()
    
    var profitOrLossAmtLabel = UILabel()
    
    var coin : Coin?
    
    var timer = Timer()
    
    var count = 0
    
    var count1 = 0
    
    var amt = 0.00 //coin?.currentPrice
    
    var percentLG = 0.0
    
    var cost2 = 0.0
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getSavedBuys()
        
        let backButton = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backTapped))
        
        let editButton   = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(moveRows))
        
        navigationItem.leftBarButtonItems = [backButton,editButton]
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh(_:)))
        
        navigationItem.rightBarButtonItems = [addButton,refreshButton]
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Crypto Data ...")
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        self.refreshControl = refreshControl
        
        tableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        
        totalInvested = 0.0
        totalInvested1 = 0.0
        profitOrLoss = 0.0
        profitOrLoss1 = 0.0
        percentLG = 0.0
        
        self.tableView.reloadData()
        
        refreshControl!.endRefreshing()
       
    }
    
    @objc func backTapped() {
        
        let vc = CryptoTableViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addTapped() {
        
        navigationController?.pushViewController(AddSingleViewController(), animated: true)
    }
    
    @objc func moveRows() {
        
        self.tableView.isEditing = true
        
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(stopMoveRows)), animated: true)
        
       
    }
    
    @objc func stopMoveRows() {
        
        self.tableView.isEditing = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(moveRows))
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
           
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
    
    func getSavedBuys() {
        
        singleCell.removeAll()
        
        singleCellBuy.removeAll()
        
        singleCellId.removeAll()
        
        let storedItems = UserDefaults.standard.object(forKey: coinSymbol + "buy") as? [[String:String]]  //[Dictionary<String, String>]?
        
        if (storedItems != nil) {
            
            for item in storedItems! {
                
                singleCell.append(item)
                
            }
            
        } else {
            
        }
        
        
        
       
        /*if let count = storedItems??.count {
            
            for i in 0..<count {
                
                singleCell.append((storedItems!![i]))
                
            }
           
        }*/
    
        print("singleCell: \(singleCell)")
        
        print("storedItems: \(String(describing: storedItems) )")

        let dataID = singleCell
        
        print("dataID: \(dataID)")
        
        if dataID.isEmpty {
            
            print("dataID is empty!")
            
        } else {
            
            for item in singleCell {
                
                if item.isEmpty {
                    
                } else {
                
                    let buyIdCode = item["dataCell"]
                    
                    let buyIdCode2 = item["idCode"]
                    
                    let buySymbol = item["id"]
                    
                    if buySymbol as! String == coinSymbol {
                        
                        singleCellBuy.append(buyIdCode! as! String)
                            
                        singleCellId.append(buyIdCode2! as! String)
                        
                        print("singleCellBuy: \(singleCellBuy)")
                        
                    }
                    
                }
                
            }
           
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
    
    
    func runCoinTotals() {
        
        var coinAmount = Double()
        
        var coinAmount1 = Double()
        
        var items = [Any]()
        
        let array = ["totalAmount","totalPrice","totalCostBasis","totalGas"]
        
        for symbol in cryptoSymbols {
            
            coinAmount = 0.0
            
            for amt in array {
                
                var investAmt = UserDefaults.standard.object(forKey: symbol + "\(amt)") as? [Any]
                
                //UserDefaults.standard.removeObject(forKey: symbol + "\(amt)")
                
                if investAmt != nil {
                    
                    for obj in investAmt ?? [] {
                        
                        items.append(obj)
                    }
                    
                    for item in items {
                        
                        coinAmount = item as? Double ?? 0.0 + coinAmount
                        
                        coinAmount1 = coinAmount + coinAmount1
                        
                    }
                    
                    if amt == "totalPrice" {
                        
                        coinAmount1 = coinAmount1 / Double(items.count)
                        
                        coin?.totalPrice = coinAmount1
                        
                    }
                    
                    if amt == "totalGas" {
                        
                        coin?.totalGas = coinAmount1
                        
                    }
                    
                    if amt == "totalAmount" {
                        
                        coin?.totalAmount = coinAmount1
                        
                    }
                    
                    if amt == "totalCostBasis" {
                        
                        totalInvested = coinAmount1
                        
                        coin?.totalCostBasis = coinAmount1
                        
                    }
                    
                    print("\(symbol)\(amt): \(items)")
                    
                    print("\(amt): \(coinAmount1)")
                    
                    coinAmount1 = 0.0
                    
                    investAmt?.removeAll()
                    
                    items.removeAll()
                 
                   
                } else {
                    
                    
                }
                
            }
            
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        CoinData.shared.delegate = self
        
        amt = coin?.currentPrice ?? 0.0
        
        profitOrLoss = 0.0
        totalInvested = 0.0
        
        getSavedBuys()
        
        tableView.reloadData()
        
    }
    
    func newPrices() {
        
        totalInvested = 0.0
        totalInvested1 = 0.0
        profitOrLoss = 0.0
        profitOrLoss1 = 0.0
        percentLG = 0.0
        
        tableView.reloadData()
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight/2))
        headerView.backgroundColor = UIColor.white
        let networthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHeight))
        networthLabel.text = coin?.name ?? "" + " Net Worth"
        networthLabel.textAlignment = .center
        networthLabel.textColor = .black
        
        headerView.addSubview(networthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHeight, width: view.frame.size.width, height: (headerHeight / 2) - netWorthHeight)
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 40.0)
        amountLabel.textColor = .black
        headerView.addSubview(amountLabel)
        
        profitOrLossLabel = UILabel(frame: CGRect(x: 0, y: 60, width: view.frame.size.width, height: headerHeight/2))
        //profitOrLossLabel.text = "Profit or Loss"
        profitOrLossLabel.textAlignment = .center
        //profitOrLossLabel.textColor = .black
        
        
        headerView.addSubview(profitOrLossLabel)
        
        profitOrLossAmtLabel.frame = CGRect(x: 0, y: netWorthHeight + 65 , width: view.frame.size.width, height: (headerHeight / 2) - netWorthHeight)
        profitOrLossAmtLabel.textAlignment = .center
        profitOrLossAmtLabel.font = UIFont.boldSystemFont(ofSize: 35.0)
        headerView.addSubview(profitOrLossAmtLabel)
        
        displayNetWorth()
        
        return headerView
    }
    
    func displayNetWorth() {
        
        runCoinTotals()
        
        amountLabel.text = "$" + CoinData.shared.coinNetWorthAsString()
        //profitOrLoss = totalInvested - coinNetWorth
        let polString = doubleToMoneyString(double: profitOrLoss)
        //let perPOL = doubleToString(double: (profitOrLoss / coin!.totalCostBasis) * 100)
        let strPer = doubleToMoneyString(double: percentLG * 100)
        profitOrLossAmtLabel.text = polString + " " + strPer + "%"  //polString + " \(perPOL)%"
        
        if profitOrLoss > 0.00 {
            
            profitOrLossLabel.text = "Net Profit"
            profitOrLossLabel.textColor = UIColor(red: 0/255, green: 170/255, blue: 14/255, alpha: 1.0)
            profitOrLossAmtLabel.textColor = UIColor(red: 0/255, green: 170/255, blue: 14/255, alpha: 1.0)
            
        }
        
        if profitOrLoss < 0.00 {
            profitOrLossLabel.text = "Net Loss"
            profitOrLossLabel.textColor = .red
            profitOrLossAmtLabel.textColor = .red
        }
        
        if profitOrLoss == 0.00 {
            profitOrLossLabel.text = "Even"
            profitOrLossLabel.textColor = .blue
            profitOrLossAmtLabel.textColor = .blue
        }
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
    
    func doubleToString(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singleCellBuy.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 420
    }
    
    func getEditData() {
        
        UserDefaults.standard.removeObject(forKey: "editBuy")
        
        let storedItems = UserDefaults.standard.object(forKey: coinSymbol + cellId) as? [Dictionary<String, String>]?
        
        addSingleBuy.removeAll()
        
        editSingleCellBuy.removeAll()
       
        if let count = storedItems??.count {
            
            for i in 0..<count {
                
                addSingleBuy.append(storedItems!![i])
            }
            
        }
    
        print("addSingleBuy: \(addSingleBuy)")
        
        print("storedFullBuy: \(String(describing: storedItems) )")

        let dataID = addSingleBuy
        
        print("dataID: \(dataID)")
        
        if dataID.isEmpty || dataID == [] {
            
            print("dataID is empty!")
            
        } else {
            
            for item in dataID {
                
                let buyIdCode2 = item["idCounter"]
                
                if buyIdCode2 == cellId {
                    
                    editSingleCellBuy.append(item)
                    
                    print("editSingleCellBuy: \(editSingleCellBuy)")
                    
                    UserDefaults.standard.set(editSingleCellBuy, forKey: "editBuy")
                    
                    editCounterInput = item["idCounter"]!
                    
                    editCoinInput = item["symbol"]!
                    
                    editDateInput = item["date"]!
                    
                    editSharesInput = item["shares"]!
                    
                    editFeesInput = item["gas"]!
                    
                    editPriceInput = item["price"]!
                    
                    editCostInput = item["costBasis"]!
                   
                }
              
            }
           
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel!.numberOfLines = 15
        
        cell.textLabel!.lineBreakMode = .byWordWrapping
        
        print("singleCellBuy: \(singleCellBuy)")
        
        let coin1 = coins[indexPath.row]
        
        cost2 = 0
        
        coin1.gainLoss = 0.00
        
        coin1.percentGainLoss = 0.00
        
        cellId = singleCellId[indexPath.row]
        
        let edit = singleCell[indexPath.row]
        
        if edit.isEmpty {
            
        } else {
            
            let shares = Double(edit["shares"] as! String) ?? 0.0
            
            let cost = Double(edit["costBasis"] as! String) ?? 0.0
            
            if shares.isNaN {
                
                
            } else {
                
                let value = amt * shares
                
                let valueToDollar = String(format: "%.7f", value)
                
                coin1.gainLoss = (value - cost)
                
                let gainLossStr = String(format: "%.2f", coin1.gainLoss)
                
                coin1.percentGainLoss = (coin1.gainLoss / cost) * 100
               
                let doubleStr = String(format: "%.2f", coin1.percentGainLoss)
                    
                cell.textLabel?.text = "\(singleCellBuy[indexPath.row])\rCurrent Price: $\(amt)\rValue: $\(valueToDollar)\rGain/Loss: $\(gainLossStr)\rGain/Loss %: \(doubleStr)%"
                
                cell.imageView?.image = coin?.image
                
                profitOrLoss = coin1.gainLoss + profitOrLoss
                
                cost2 = cost + cost2
                
                percentLG = profitOrLoss / cost2
                
                print("cellId: \(cellId)")
                    
            }
            
        }
            
       return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellId = singleCellId[indexPath.row]
        print("cellId: \(cellId)")
        getEditData()
        let editVC = EditSingleViewController()
        editVC.coin = coins[indexPath.row]
        print("coinSymbol: \(coinSymbol)")
        navigationController?.pushViewController(editVC, animated: true)
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
            
            UserDefaults.standard.removeObject(forKey: coinSymbol + cellId)
            
            singleCellBuy.remove(at: indexPath.row)
            
            singleCellId.remove(at: indexPath.row)
            
            //addSingleBuy.remove(at: indexPath.row)
            
            singleCell.remove(at: indexPath.row)
            
            
            //UserDefaults.standard.removeObject(forKey: coinSymbol + "cell")
            
            print("Item deleted!")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.reloadData()
        
        }
    }

}

