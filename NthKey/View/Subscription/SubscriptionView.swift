//
//  SubscriptionView.swift
//  SubscriptionView
//
//  Created by Sergey Vinogradov on 03.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct SubscriptionView: View {
    var model: SubscriptionViewModel

    var body: some View {
        Text((model.hasSubscription ? "Have " : "Don't ") + "have subscription")
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(model: SubscriptionViewModel(subsManager: SubscriptionManager.mock))
    }
}
