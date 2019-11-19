//
//  CoinData.swift
//  Crypto Tracker
//
//  Created by Better Search, LLC on 4/30/18.
//  Copyright © 2019 Eric Cook. All rights reserved.
//

import UIKit
//import Alamofire

var historicalData = [Double]()

var coins = [Coin]()

class CoinData {
    
    static let shared = CoinData()
    
    weak var delegate : CoinDataDelegate?
    
    private init() {
        
        let symbols2 = UserDefaults.standard.array(forKey: "symbols") //?? []
        
        if symbols2 != nil {
            
            if symbols2!.isEmpty  {
                
                let symbols1 = ["BTC","XRP","XMR","ETH","LTC","BCH","EOS","BNB","BSV","ADA","XLM","ZEC","DASH","NEO"]
                
                UserDefaults.standard.set(symbols1, forKey: "symbols")
                
                cryptoSymbols = symbols1
                
                for symbol in symbols1 {
                    
                    let coin = Coin(symbol: symbol)
                    
                    coins.append(coin)
                }
                
            } else {
                
                print("Symbols: \(symbols2!)")
                
                for symbol in symbols2! {
                    
                    let coin = Coin(symbol: symbol as! String)
                    
                    coins.append(coin)
                }
            }
            
        } else {
            
            let symbols1 = ["BTC","XRP","XMR","ETH","LTC","BCH","EOS","BNB","BSV","ADA","XLM","ZEC","DASH","NEO"]
            
            UserDefaults.standard.set(symbols1, forKey: "symbols")
            
            cryptoSymbols = symbols1
            
            for symbol in symbols1 {
                
                let coin = Coin(symbol: symbol)
                
                coins.append(coin)
            }
        }
        
    }
    
    func html() -> String {
        var html = "<h1>My Crypto Report</h1>"
        html += "<h2>Net Worth: \(netWorthAsString())</h2>"
        html += "<ul>"
        for coin in coins {
            if coin.amount != 0.0 {
                html += "<li>\(coin.symbol) - I own: \(coin.amount) - Valued at: \(doubleToMoneyString(double: coin.amount * coin.price))</li>"
            }
        }
        html += "</ul>"
        
        return html
    }
    
    func netWorthAsString() -> String {
        var netWorth = 0.0
        for coin in coins {
            netWorth += coin.amount * coin.price
        }
        
        return doubleToMoneyString(double: netWorth)
    }
    
    func getPrices() {
        var listOfSymbols = ""
        for coin in coins {
            listOfSymbols += coin.symbol
            if coin.symbol != coins.last?.symbol {
                listOfSymbols += ","
            }
        }
        
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD") {
            
            let data = try? Data(contentsOf: url)
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let object = json as? [String: Any] {
                
            //Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD").responseJSON { (response) in
                //if let json = response.result.value as? [String:Any] {
                for coin in coins {
                    if let coinJSON = object[coin.symbol] as? [String:Double] {
                        if let price = coinJSON["USD"] {
                            coin.price = price
                            UserDefaults.standard.set(price, forKey: coin.symbol)
                        }
                    }
                }
                self.delegate?.newPrices?()
            }
        }
    }
    
    func getPercents() {
        
        for coin in coins {
            
            for name in percentDic {
                
                if name.key == coin.symbol {
                    
                    coin.percentChange = name.value
                    
                }
                
            }
            
        }
        
        //print("percentData: \(percentData)")
        
        print("percentDic: \(percentDic)")
        
    }
    
    func getYesterdaysClose() {
        
        yesterdayData.removeAll()
        
        yesterdayDic.removeAll()
        
        if cryptoSymbols.isEmpty {
            
            //getSavedCryptoSymbols()
            
            print("CryptoSymbols and local storage are empty!")
            
        } else {
            
            for symbol in cryptoSymbols {
                
                do {
                    
                    if let url = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(symbol)&tsyms=USD") {
                        
                        let data = try? Data(contentsOf: url)
                        
                        let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                        
                        if let object = json as? [String: Any] {
                            
                            if let raw = object["RAW"] as? [String:Any] {
                                
                                if let coin1 = raw["\(symbol)"] as? [String:Any] {
                                    
                                    if let usd = coin1["USD"] as? [String:Any] {
                                        
                                        if let close = usd["OPENDAY"] as? Double {
                                            
                                            let name = String(format: "%.2f", close)
                                            
                                            let newValue = yesterdayDic.updateValue(name, forKey: symbol)
                                            
                                            UserDefaults.standard.set(newValue, forKey: "yesterdayDic")
                                            
                                        }
                                        
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
            
            CoinData.shared.delegate?.newYesterday?()
        }
        
    }
    
    func getClose() {
        
        for coin in coins {
            
            for name in yesterdayDic {
                
                if name.key == coin.symbol {
                    
                    coin.yesterdayClose = name.value
                    
                }
                
            }
            
        }
        
        //print("yesterdayData: \(yesterdayData)")
        
        print("yesterdayDic: \(yesterdayDic)")
        
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
    
}


@objc protocol CoinDataDelegate : class {
    @objc optional func newPrices()
    @objc optional func newHistory()
    @objc optional func newName()
    @objc optional func newPercent()
    @objc optional func newYesterday()
}

class Coin {
    var symbol = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalData = [Double]()
    var name = String()
    var percentChange = String()
    var yesterdayClose = String()
    
    init(symbol: String) {
        self.symbol = symbol
        if let image = UIImage(named: symbol) {
            self.image = image
        }
        self.price = UserDefaults.standard.double(forKey: symbol)
        //self.percentChange = UserDefaults.standard.string(forKey: symbol + "percent")!
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
            self.historicalData = history
        }
        if let names = UserDefaults.standard.string(forKey: symbol + "name") {
            self.name = names
        }
        /*if let yesterdays = UserDefaults.standard.string(forKey: symbol + "yesterday") {
         self.yesterdayClose = yesterdays
         }*/
        
    }
    
    func getHistoricalDataMonth() {
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30") {
            
            let data = try? Data(contentsOf: url)
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let object = json as? [String: Any] {
             
                if let pricesJSON = object["Data"] as? [[String:Double]] {
                    self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory?()
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                }
            }
        }
        
    }
    
    func getHistoricalDataDay() {
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/histohour?fsym=\(symbol)&tsym=USD&limit=24") {
            
            let data = try? Data(contentsOf: url)
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let object = json as? [String: Any] {
              
                if let pricesJSON = object["Data"] as? [[String:Double]] {
                    self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                        
                    }
                    CoinData.shared.delegate?.newHistory?()
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                    
                }
            }
        }
        
    }
    
    
    func getHistoricalDataYear() {
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=365") {
            
            let data = try? Data(contentsOf: url)
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let object = json as? [String: Any] {
              
                if let pricesJSON = object["Data"] as? [[String:Double]] {
                    self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory?()
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                }
            }
        }
    }
    
    
    func getHistoricalDataThreeYear() {
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=1095") {
            
            let data = try? Data(contentsOf: url)
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let object = json as? [String: Any] {
               
                if let pricesJSON = object["Data"] as? [[String:Double]] {
                    self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory?()
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                }
            }
        }
    }
    
    func getHistoricalDataFiveYear() {
        
        if let url = URL(string: "https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=1825") {
            
            let data = try? Data(contentsOf: url)
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let object = json as? [String: Any] {
           
                if let pricesJSON = object["Data"] as? [[String:Double]] {
                    self.historicalData = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalData.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory?()
                    UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
                }
            }
        }
    }
    
    func priceAsString() -> String {
        if price == 0.0 {
            return "Loading..."
        }
        
        return CoinData.shared.doubleToMoneyString(double: price)
    }
    
    func amountAsString() -> String {
        return CoinData.shared.doubleToMoneyString(double: amount * price)
    }
    
    
}


