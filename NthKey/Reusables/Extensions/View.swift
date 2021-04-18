//
//  View.swift
//  View
//
//  Created by Sergey Vinogradov on 19.04.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

extension View {
    var toAnyView: AnyView {
        AnyView(self)
    }
}
