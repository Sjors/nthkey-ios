//
//  Destination.swift
//  Destination
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

struct Destination : Identifiable {
    public let description: String
    public let id: String
    
    init(output: PSBTOutput) {
        self.description = String(output.txOutput.amount) + " sats" + ": " + output.txOutput.address!.description
        self.id = output.id
    }
    
}
