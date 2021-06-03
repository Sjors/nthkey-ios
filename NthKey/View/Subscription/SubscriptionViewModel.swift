//
//  SubscriptionViewModel.swift
//  SubscriptionViewModel
//
//  Created by Sergey Vinogradov on 06.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import Combine

final class SubscriptionViewModel: ObservableObject {
    @Published private(set) var state: State = State.initial
    @Published var currentProductIndex: Int = 0
    @Published var purchased: Bool = false
    @Published var disablePurchaseButton: Bool = false

    var productTitles: [String] {
        subsManager.products.map{ $0.subscriptionPeriod?.localizedPeriod() ?? $0.localizedTitle }
    }

    var productPrices: [String] {
        subsManager.products.map{ $0.formattedPrice() }
    }

    var productDescriptions: [String] {
        subsManager.products.map{ $0.localizedDescription }
    }

    private var cancellables = Set<AnyCancellable>()
    private let subsManager: SubscriptionManager

    init(subsManager: SubscriptionManager) {
        self.subsManager = subsManager

        setupObservables()
    }

    func purchaseCurrentProduct() {
        guard currentProductIndex < subsManager.products.count else { return }
        disablePurchaseButton = true
        let product = subsManager.products[currentProductIndex]
        subsManager.purchase(product: product)
    }

    func restorePurchases() {
        disablePurchaseButton = true
        subsManager.restorePurchases()
    }

    // MARK: - Private

    func setupObservables() {
        subsManager
            .$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.state = ( products.count == 0 ? .initial : .ready )
            }
            .store(in: &cancellables)

        subsManager
            .$hasSubscription
            .receive(on: DispatchQueue.main)
            .assign(to: \.purchased, on: self)
            .store(in: &cancellables)

        subsManager
            .$state
            .sink { [weak self] managerState in
                guard let self = self,
                      self.disablePurchaseButton else { return }
                switch managerState {
                case .notPurchased, .failed(_):
                    self.disablePurchaseButton = false
                default:
                    break
                }

            }
            .store(in: &cancellables)
    }
}

// MARK: FSM
extension SubscriptionViewModel {
    enum State {
        case initial
        case ready
    }
}

#if DEBUG
extension SubscriptionViewModel {
    static var readyToPurchaseMock: SubscriptionViewModel {
        let result = SubscriptionViewModel(subsManager: SubscriptionManager.mock)
        result.state = .ready
        return result
    }
}
#endif
