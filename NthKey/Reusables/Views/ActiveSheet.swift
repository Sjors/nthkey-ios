//
//  ActiveSheet.swift
//  ActiveSheet
//
//  Created by Sergey Vinogradov on 26.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

/// Used for separate `.sheet()` operator targets in views
enum ActiveSheet: Identifiable {
    /// Show QR scanner
    case scanner

    /// Show subscritpion view where user can select one to purchase or restore
    case subscription

    var id: Int {
        hashValue
    }
}
