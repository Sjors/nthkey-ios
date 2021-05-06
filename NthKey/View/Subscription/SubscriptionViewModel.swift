//
//  SubscriptionViewModel.swift
//  SubscriptionViewModel
//
//  Created by Sergey Vinogradov on 06.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

final class SubscriptionViewModel {

    var hasSubscription: Bool {
        subsManager.hasSubscription
    }

    private var subsManager: SubscriptionManager

    init(subsManager: SubscriptionManager) {
        self.subsManager = subsManager
    }
}
