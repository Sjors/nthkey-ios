//
//  SubscriptionViewModel.swift
//  SubscriptionViewModel
//
//  Created by Sergey Vinogradov on 06.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation


final class SubscriptionViewModel: ObservableObject {
    @Published var currentProductIndex: Int = 0

    var productTitles: [String] {
        subsManager.products.map{ $0.subscriptionPeriod?.localizedPeriod() ?? $0.localizedTitle }
    }

    var productPrices: [String] {
        subsManager.products.map{ $0.formattedPrice() }
    }

    var productDescriptions: [String] {
        subsManager.products.map{ $0.discounts.compactMap{ $0.localizedDiscount() }
            .joined(separator: ", ") }
    }

    private var subsManager: SubscriptionManager

    init(subsManager: SubscriptionManager) {
        self.subsManager = subsManager
    }

    func purchaseCurrentProduct() {
        let product = subsManager.products[currentProductIndex]
        _ = subsManager.purchase(product: product)
    }

    func restorePurchases() {
        subsManager.restorePurchases()
    }
}
