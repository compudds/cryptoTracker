//
//  CoinViewController.swift
//  Crypto Tracker
//
//  Created by Better Search, LLC on 5/4/18.
//  Copyright © 2019 Eric Cook. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHeight : CGFloat = 300.0
private let imageSize : CGFloat = 100.0
private let priceLabelHeight : CGFloat = 25.0

private let headerHeight : CGFloat = 50.0
private let historyHeight : CGFloat = 45.0

class CoinViewController: UIViewController, CoinDataDelegate, ChartDelegate {
    
    var chart = Chart()
    
    var historicalLabel = UILabel()
    
    var historicalButtonDay = UIButton()
    var historicalButtonMonth = UIButton()
    var historicalButtonYear = UIButton()
    var historicalButtonThreeYear = UIButton()
    var historicalButtonFiveYear = UIButton()

    var coin : Coin?
    var priceLabel = UILabel()
    var youOwnLabel = UILabel()
    var worthLabel = UILabel()
    var nameLabel = UILabel()
    var costBasisLabel = UILabel()
    var nameFull = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.delegate = self
        
        //labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
       
        if let coin = coin {
            CoinData.shared.delegate = self
            edgesForExtendedLayout = []
            view.backgroundColor = UIColor.white
            title = coin.symbol
            
            //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
            
            let historyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: historyHeight))
            historyLabel.text = "Historical Information for \(coin.name) - \(coin.symbol)"
            historyLabel.textAlignment = .center
            historyLabel.textColor = .black
            view.addSubview(historyLabel)
            
            historicalButtonDay = UIButton(frame: CGRect(x: 0, y: 50, width: 75, height: 50))
            historicalButtonDay.backgroundColor = .white
            historicalButtonDay.setTitleColor(.blue, for: .normal)
            historicalButtonDay.setTitle("24 Hrs", for: .normal)
            historicalButtonDay.addTarget(self, action:#selector(self.displayHistoricalInfoDay), for: .touchUpInside)
            view.addSubview(historicalButtonDay)
            
            historicalButtonMonth = UIButton(frame: CGRect(x: 75, y: 50, width: 75, height: 50))
            historicalButtonMonth.backgroundColor = .white
            historicalButtonMonth.setTitleColor(.blue, for: .normal)
            historicalButtonMonth.setTitle("30 Days", for: .normal)
            historicalButtonMonth.addTarget(self, action:#selector(self.displayHistoricalInfoMonth), for: .touchUpInside)
            view.addSubview(historicalButtonMonth)
            
            historicalButtonYear = UIButton(frame: CGRect(x: 150, y: 50, width: 75, height: 50))
            historicalButtonYear.backgroundColor = .white
            historicalButtonYear.setTitleColor(.blue, for: .normal)
            historicalButtonYear.setTitle("1 Year", for: .normal)
            historicalButtonYear.addTarget(self, action:#selector(self.displayHistoricalInfo1Y), for: .touchUpInside)
            view.addSubview(historicalButtonYear)
            
            historicalButtonThreeYear = UIButton(frame: CGRect(x: 225, y: 50, width: 75, height: 50))
            historicalButtonThreeYear.backgroundColor = .white
            historicalButtonThreeYear.setTitleColor(.blue, for: .normal)
            historicalButtonThreeYear.setTitle("3 Years", for: .normal)
            historicalButtonThreeYear.addTarget(self, action:#selector(self.displayHistoricalInfo3Y), for: .touchUpInside)
            view.addSubview(historicalButtonThreeYear)
            
            historicalButtonFiveYear = UIButton(frame: CGRect(x: 305, y: 50, width: 75, height: 50))
            historicalButtonFiveYear.backgroundColor = .white
            historicalButtonFiveYear.setTitleColor(.blue, for: .normal)
            historicalButtonFiveYear.setTitle("5 Years", for: .normal)
            historicalButtonFiveYear.addTarget(self, action:#selector(self.displayHistoricalInfo5Y), for: .touchUpInside)
            view.addSubview(historicalButtonFiveYear)
            
            self.displayHistoricalInfoDay()
            
            let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHeight + 190, width: imageSize, height: imageSize))
            imageView.image = coin.image
            view.addSubview(imageView)
            
            nameLabel.frame = CGRect(x: 0, y: (chartHeight + imageSize) + 190, width: view.frame.size.width, height: priceLabelHeight)
            nameLabel.textAlignment = .center
            nameLabel.textColor = .black
            view.addSubview(nameLabel)
            
            priceLabel.frame = CGRect(x: 0, y: (chartHeight + imageSize) + 210, width: view.frame.size.width, height: priceLabelHeight)
            priceLabel.textAlignment = .center
            priceLabel.textColor = .black
            view.addSubview(priceLabel)
            
            youOwnLabel.frame = CGRect(x: 0, y: (chartHeight + imageSize + priceLabelHeight * 2) + 190, width: view.frame.size.width, height: priceLabelHeight)
            youOwnLabel.textAlignment = .center
            youOwnLabel.textColor = .black
            youOwnLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            view.addSubview(youOwnLabel)
            
            worthLabel.frame = CGRect(x: 0, y: (chartHeight + imageSize + priceLabelHeight * 3) + 190, width: view.frame.size.width, height: priceLabelHeight)
            worthLabel.textAlignment = .center
            worthLabel.textColor = .black
            worthLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            view.addSubview(worthLabel)
            
            newPrices()
            
        }
        
        /*if #available(iOS 13, *)
            {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                statusBar.backgroundColor = UIColor.systemBackground
                UIApplication.shared.keyWindow?.addSubview(statusBar)
            }*/
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        
        noInternetConnection()
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("CoinView Internet connection OK")
            
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
    
    @objc func displayHistoricalInfoDay() {
        
        removeSubview()
        
        chart.removeAllSeries()
        
        coin!.getHistoricalDataDay()
        
        chart.frame = CGRect(x: 0, y: 150, width: view.frame.size.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = [0,2,4,6,8,10,12,14,16,18,20,22,24]
        chart.xLabelsFormatter = { String(Int(round(24 - $1))) }
        self.view.addSubview(chart)
        
        let xLabel = UILabel(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.height))
        xLabel.tag = 100
        xLabel.text = "Hours"
        xLabel.textAlignment = .center
        view.addSubview(xLabel)
        
        print("historicalData: \(coin!.historicalData)")
        
        newHistory()
        
    }
    
    @objc func displayHistoricalInfoMonth() {
        
        removeSubview()
        
        chart.removeAllSeries()
        
        coin!.getHistoricalDataMonth()
        
        chart.frame = CGRect(x: 0, y: 150, width: view.frame.size.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = [0,5,10,15,20,25,30]
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) }
        self.view.addSubview(chart)
        
        let xLabel = UILabel(frame: CGRect(x: 0, y: 95, width: view.frame.size.width, height: view.frame.size.height))
        xLabel.tag = 100
        xLabel.text = "Days"
        xLabel.textAlignment = .center
        view.addSubview(xLabel)
        
        print("historicalData: \(coin!.historicalData)")
        
        newHistory()
        
    }
    
    @objc func displayHistoricalInfo1Y() {
        
        removeSubview()
        
        chart.removeAllSeries()
        
        coin!.getHistoricalDataYear()
        
        chart.frame = CGRect(x: 0, y: 150, width: view.frame.size.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = [0,30,60,90,120,150,180,210,240,270,300,330,365]
        chart.xLabelsFormatter = { String(Int(round(365 - $1))) }
        self.view.addSubview(chart)
        
        let xLabel = UILabel(frame: CGRect(x: 0, y: 95, width: view.frame.size.width, height: view.frame.size.height))
        xLabel.tag = 100
        xLabel.text = "Days"
        xLabel.textAlignment = .center
        view.addSubview(xLabel)
        
        print("historicalData: \(coin!.historicalData)")
        
        newHistory()
        
    }
    
    @objc func displayHistoricalInfo3Y() {
        
        removeSubview()
        
        chart.removeAllSeries()
        
        coin!.getHistoricalDataThreeYear()
        
        chart.frame = CGRect(x: 0, y: 150, width: view.frame.size.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = [0,180,365,730,912,1095]
        chart.xLabelsFormatter = { String(Int(round(1095 - $1))) }
        self.view.addSubview(chart)
        
        let xLabel = UILabel(frame: CGRect(x: 0, y: 95, width: view.frame.size.width, height: view.frame.size.height))
        xLabel.tag = 100
        xLabel.text = "Days"
        xLabel.textAlignment = .center
        view.addSubview(xLabel)
        
        print("historicalData: \(coin!.historicalData)")
        
        newHistory()
        
    }
    
    @objc func displayHistoricalInfo5Y() {
        
        removeSubview()
        
        chart.removeAllSeries()
        
        coin!.getHistoricalDataFiveYear()
        
        chart.frame = CGRect(x: 0, y: 150, width: view.frame.size.width, height: chartHeight)
        chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
        chart.xLabels = [0,180,365,730,912,1095,1277,1460,1642,1825]
        chart.xLabelsFormatter = { String(Int(round(1825 - $1))) }
        self.view.addSubview(chart)
        
        let xLabel = UILabel(frame: CGRect(x: 0, y: 95, width: view.frame.size.width, height: view.frame.size.height))
        xLabel.tag = 100
        xLabel.text = "Days"
        xLabel.textAlignment = .center
        view.addSubview(xLabel)
        
        print("historicalData: \(coin!.historicalData)")
        
        newHistory()
        
    }
    
    func removeSubview() {
        
        if let viewWithTag = self.view.viewWithTag(100) {
            
            viewWithTag.removeFromSuperview()
        
        } else {
            
            print("No!")
            
        }
    }
    
    @objc func editTapped() {
        /*if let coin = coin {
            let alert = UIAlertController(title: "How much \(coin.symbol) do you own & cost basis?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Amount Owned"
                textField.keyboardType = .decimalPad
                if self.coin?.amount != 0.0 {
                    textField.text = String(coin.amount)
                }
            }
        
            alert.addTextField { (textField2) in
                textField2.placeholder = "Price/share $"
                textField2.keyboardType = .decimalPad
                if self.coin?.costBasis != 0.0 {
                    textField2.text = String(coin.costBasis)
                }
            }
            
            alert.addTextField { (textField3) in
                textField3.placeholder = "Commission/Gas/Fees $"
                textField3.keyboardType = .decimalPad
                if self.coin?.amount != 0.0 {
                    /*let amt = coin.amount * coin.costBasis
                    let amt2 = coin.investmentAmt - amt
                    let amt3 = self.doubleToMoneyString(double: amt2)
                    textField3.text = String(amt3)*/
                    textField3.text = String(coin.gas)
                }
            }
            
            alert.addTextField { (textField4) in
                textField4.placeholder = "Original Investment Amt. $"
                textField4.keyboardType = .decimalPad
                if self.coin?.investmentAmt != 0.0 {
                    textField4.text = String(coin.investmentAmt)
                }
            }
            
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
               
                if let text = alert.textFields?[0].text {
                    if let amount = Double(text) {
                        self.coin?.amount = amount
                        UserDefaults.standard.set(amount, forKey: coin.symbol + "amount")
                        self.newPrices()
                    }
                }
                
                if let text = alert.textFields?[1].text {
                    if let costBasis = Double(text) {
                        self.coin?.costBasis = costBasis
                        UserDefaults.standard.set(costBasis, forKey: coin.symbol + "costBasis")
                        self.newPrices()
                    }
                    
                }
                
                if let text = alert.textFields?[2].text {
                    if let gas = Double(text) {
                        self.coin?.gas = gas
                        UserDefaults.standard.set(gas, forKey: coin.symbol + "gas")
                        self.newPrices()
                    }
                    
                if let text = alert.textFields?[3].text {
                    if let invAmt = Double(text) {
                        self.coin?.investmentAmt = invAmt
                        UserDefaults.standard.set(invAmt, forKey: coin.symbol + "investmentAmt")
                        self.newPrices()
                    }
                    
                }
                
                
                    
                }
                
            }))
            self.present(alert, animated: true, completion: nil)
        }*/
    }
    
    func newHistory() {
        if let coin = coin {
            let series = ChartSeries(coin.historicalData)
            series.area = true
            chart.add(series)
        }
    }
    
    func newPrices() {
        if let coin = coin {
            self.nameLabel.text = "\(coin.name) - \(coin.symbol)"
            priceLabel.text = "Price $" + coin.priceAsString() + " Cost $\(coin.costBasis)"
            worthLabel.text = "$" + coin.amountAsString()
            youOwnLabel.text = "You own: \(coin.amount) \(coin.symbol)"
            costBasisLabel.text = "Cost Basis: $" +  doubleToMoneyString(double: Double(coin.costBasis))
        }
    }
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at `seriesIndex` is that which has been touched
                let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex)
                print(value as Any)
                
                historicalLabel.text = ""
                
                historicalLabel = UILabel(frame: CGRect(x: 175, y: 115, width:250, height: 50))
                
                historicalLabel.text = doubleToMoneyString(double: Double(value!))
                
                view.addSubview(historicalLabel)
                
            }
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
    
    func didFinishTouchingChart(_ chart: Chart) {
        
        historicalLabel.text = ""
        view.removeFromSuperview()
        //labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
        
    }
    
    
}
