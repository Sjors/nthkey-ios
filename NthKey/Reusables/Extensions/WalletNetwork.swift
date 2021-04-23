//
//  WalletNetwork.swift
//  WalletNetwork
//
//  Created by Sergey Vinogradov on 24.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

enum WalletNetwork: String, CaseIterable {
    case mainnet = "Mainnet"
    case testnet = "Testnet"

    var title: String { self.rawValue }
}

extension WalletNetwork: Identifiable {
    var id: String { self.rawValue }
}

extension WalletNetwork {
    var networkValue: Network {
        switch self {
        case .mainnet:
            return .mainnet

        case .testnet:
            return .testnet
        }
    }

    static func valueFromNetwork(_ value: Network) -> WalletNetwork {
        switch value {
        case .mainnet:
            return .mainnet
        case .testnet:
            return .testnet
        }
    }
}

/// For work with core data
extension WalletNetwork {
    var int16Value: Int16 {
        switch self {
        case .mainnet:
            return 0
        case .testnet:
            return 1
        }
    }

    static func valueFromInt16(_ value: Int16) -> WalletNetwork? {
        switch value {
        case 0:
            return .mainnet
        case 1:
            return .testnet
        default:
            return nil
        }
    }
}

/// For work with UserDefaults
extension WalletNetwork {
    var stringKey: String {
        String(self.int16Value)
    }

    static func valueFromStringKey(_ key: String) -> WalletNetwork? {
        guard let value = Int16(key) else { return nil }
        return valueFromInt16(value)
    }
}
