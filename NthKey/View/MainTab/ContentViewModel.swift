//
//  ContentViewModel.swift
//  ContentViewModel
//
//  Created by Sergey Vinogradov on 11.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation


enum ContentViewTab: Hashable {
    case addresses
    case sign
    case settings
}

class ContentViewModel: ObservableObject {
    @Published var selectedTab: ContentViewTab = .addresses

    // TODO: remove constant model after avoiding constant redraw
    let addressesModel: AddressesViewModel
    let signViewModel: SignViewModel
    let settingsModel: SettingsViewModel

    private let dataManager: DataManager
    private let subsManager: SubscriptionManager

    init(dataManager: DataManager, subsManager: SubscriptionManager) {
        self.dataManager = dataManager
        self.subsManager = subsManager

        addressesModel = AddressesViewModel(dataManager: dataManager)
        signViewModel = SignViewModel(dataManager: dataManager, subsManager: subsManager)
        settingsModel = SettingsViewModel(dataManager: dataManager, subsManager: subsManager)
    }
}
