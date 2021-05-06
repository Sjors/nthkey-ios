//
//  SubscriptionManager.swift
//  SubscriptionManager
//
//  Created by Sergey Vinogradov on 03.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

final class SubscriptionManager: ObservableObject {
    @Published var hasSubscription: Bool = false
}

#if DEBUG
extension SubscriptionManager {
    static var mock: SubscriptionManager = SubscriptionManager()
}
#endif
