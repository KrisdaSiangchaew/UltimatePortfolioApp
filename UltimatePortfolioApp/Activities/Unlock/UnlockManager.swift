//
//  UnlockManager.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 12/6/2564 BE.
//

import Combine
import StoreKit

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    enum RequestState {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchased
        case deferred
    }
    
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }
    
    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()
    
    @Published var requestState = RequestState.loading
    
    var canMakePayment: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    init(dataController: DataController) {
        // Store the data controller we were sent
        self.dataController = dataController
        
        // Prepare to look for our unlock product
        let productIDs = Set(["com.krisdasiangchaew.UltimatePortfolioApp.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)
        
        // This is required because we inherit from NSObject
        super.init()
        
        // Start watching the payment queue
        SKPaymentQueue.default().add(self)
        
        // Avoid starting the product request if our unlock has already happened
        guard dataController.fullVersionUnlocked == false else { return }
        
        // Set ourselves up to be notified when the product request completes
        request.delegate = self
        
        // Start the request
        request.start()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)
                
                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    
                    queue.finishTransaction(transaction)
                    
                case .deferred:
                    self.requestState = .deferred
                    
                default:
                    break
                }
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them
            self.loadedProducts = response.products
            
            guard let unlock = response.products.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }
            
            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
            }
            
            self.requestState = .loaded(unlock)
        }
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore(product: SKProduct) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
