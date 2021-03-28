//
//  Network.swift
//  Network
//
//  Created by Sergey Vinogradov on 24.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

extension Network {
    var int16Value: Int16 {
        switch self {
        case .mainnet:
            return 0
        case .testnet:
            return 1
        }
    }

    var title: String {
        switch self {
        case Network.mainnet:
            return "Mainnet"
        case Network.testnet:
            return "Testnet"
        }
    }

    static func valueFromInt16(_ value: Int16) -> Network? {
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

extension Network: CaseIterable {
    public typealias AllCases = [Network]

    public static var allCases: AllCases {
        get { return [.mainnet, .testnet] }
    }
}
