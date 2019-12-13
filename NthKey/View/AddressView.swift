//
//  AddressView.swift
//  AddressView
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI

struct AddressView : View {
    let address: MultisigAddress

    init(_ address: MultisigAddress) {
        self.address = address
    }
    
    var body: some View {
        Text(address.description).font(.system(.body, design: .monospaced))
    }
}
