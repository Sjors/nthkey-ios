//
//  SubscriptionManager.swift
//  SubscriptionManager
//
//  Created by Sergey Vinogradov on 03.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine
import StoreKit

final class SubscriptionManager: NSObject, ObservableObject {
#if DEBUG
    @Published private(set) var hasSubscription: Bool = true
#else
    @Published private(set) var hasSubscription: Bool = false
#endif
    @Published private(set) var products: [SKProduct] = []
    @Published private(set) var state: State = .initial

    // Used for direct user notifications about purchase flow
    let purchasePublisher = PassthroughSubject<(String, Bool), Never>()

    static var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    private var totalRestoredPurchases = 0

    private let identifiers: [String]

    init(identifiers: [String]) {
        self.identifiers = identifiers
        super.init()

        checkPurchaseStatus()
    }

    // MARK: - Public

    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }

    func prepareData() {
        getProducts()
        state = .requestProducts
    }

    @discardableResult
    func purchase(product: SKProduct) -> Bool {
        guard SubscriptionManager.canMakePayments else { return false }

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        state = .startPurchase
        return true
    }

    func restorePurchases() {
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
        state = .startRestore
    }

    // MARK: - Private

    private func getProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        request.start()
    }

    private func checkPurchaseStatus() {
        guard let date = UserDefaults.subscriptionRenewalDate else { return }
        hasSubscription = Date() < date
    }

    /// Allow to have raw estimation of subscription without validation
    private func checkExpirationDateFromPayment(_ payment: SKPayment) {
        let productId = payment.productIdentifier
        for item in ["month": (1,0), "year": (0,1)] {
            guard productId.contains(item.key) else { continue }

            var dateComponent = DateComponents()
            dateComponent.month = item.value.0
            dateComponent.year = item.value.1

            let date = Calendar.current.date(byAdding: dateComponent, to: Date())
            UserDefaults.subscriptionRenewalDate = date
            checkPurchaseStatus()
        }
    }
}

extension SubscriptionManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        #if DEBUG
        let badProducts = response.invalidProductIdentifiers
        if !badProducts.isEmpty {
            print("Next products are not on the store anymore:\(badProducts.description)")
        }
        #endif

        products = response.products
        state = .receivedProducts

        // Here we try to ask if iAP still purchased, because we didn't validate receipt, yet.
        guard let date = UserDefaults.subscriptionRenewalDate,
              Date() > date,
              products.count == 1,
              let unique = products.first else { return }
        purchase(product: unique)
    }
}

extension SubscriptionManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                purchasePublisher.send(("Purchased ",true))
                checkExpirationDateFromPayment(transaction.payment)
                state = .purchased
            case .restored:
                totalRestoredPurchases += 1
                purchasePublisher.send(("Restored ",true))
                checkExpirationDateFromPayment(transaction.payment)
                state = .purchased
            case .failed:
                if let error = transaction.error as? SKError {
                    purchasePublisher.send(("Payment Error \(error.code) ",false))
                    state = .failed(error)
                }
            case .deferred:
                purchasePublisher.send(("Payment Deferred ",false))
            case .purchasing:
                purchasePublisher.send(("Payment in Process ",false))
            default:
                break
            }

            guard !(transaction.transactionState == .purchasing || transaction.transactionState == .deferred) else {
                return
            }
            
            queue.finishTransaction(transaction)
        }
    }

    // Sent when all transactions from the user's purchase history have successfully been added back to the queue.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        guard totalRestoredPurchases != 0 else {
            purchasePublisher.send(("IAP: No purchases to restore!",false))
            state = .notPurchased
            return
        }

        purchasePublisher.send(("IAP: Purchases successfull restored!",true))
        state = .purchased
    }

    // Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        guard let error = error as? SKError else { return }
        let reason = error.code != .paymentCancelled ? " Restore" : ""
        purchasePublisher.send(("IAP\(reason) Error: " + error.localizedDescription, false))
        state = .failed(error)
    }

    // TODO: Possible should implement for any transactions which will be revoked
    // func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
}

extension SubscriptionManager: SKRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        purchasePublisher.send(("Purchase request failed ",false))
        state = .failed(error)
    }
}

// MARK: FSM
extension SubscriptionManager {
    enum State {
        case initial
        case requestProducts
        case receivedProducts
        case startPurchase
        case startRestore
        case purchased
        case notPurchased
        case failed(Error)
    }
}

#if DEBUG
extension SubscriptionManager {
    static var mock: SubscriptionManager = SubscriptionManager(identifiers: ["com.nthkey.monthly"])

    static var alreadyBought: SubscriptionManager {
        let result = SubscriptionManager(identifiers: ["com.test.subscription"])
        // Here we can use #if targetEnvironment(simulator) and set date accordingly or just set flag directly
        result.hasSubscription = true
        return result
    }
}
#endif
