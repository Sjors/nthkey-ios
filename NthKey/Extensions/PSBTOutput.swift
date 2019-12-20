//
//  PSBTOutput.swift
//  PSBTOutput
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

extension PSBTOutput : Identifiable {
    public var id: String {
        return self.txOutput.address! + String(self.txOutput.amount)
    }
}
