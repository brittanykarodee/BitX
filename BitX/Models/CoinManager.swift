//
//  CoinManager.swift
//  BitX
//
//  Created by Brittany P Jenkins
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "d3727cd8-57ee-443b-977f-9eaeb7485ed3"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    func getCoinPrice(for currency: String) {
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
                task.resume()
                
            }
        }
        
        func parseJSON(_ data: Data) -> Double? {
            
            let decoder = JSONDecoder()
            
            do {
                
                let decodedData = try decoder.decode(CoinData.self, from: data)
                let lastPrice = decodedData.rate
                print(lastPrice)
                return lastPrice
                
            } catch {
                self.delegate?.didFailWithError(error: error)
                print(error)
                return nil
                
            }
            
        }
    
    }
