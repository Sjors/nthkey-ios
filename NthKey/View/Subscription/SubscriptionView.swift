//
//  SubscriptionView.swift
//  SubscriptionView
//
//  Created by Sergey Vinogradov on 03.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var subsManager: SubscriptionManager

    var body: some View {
        Text((subsManager.hasSubscription ? "Have " : "Don't ") + "have subscription")
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .environmentObject(SubscriptionManager.mock)
    }
}
