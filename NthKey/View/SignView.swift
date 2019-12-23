//
//  SignView.swift
//  SignView
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import SwiftUI
import LibWally

struct SignView : View {
    @ObservedObject var defaults = UserDefaultsManager()
    @ObservedObject var sign = SignViewController()

    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 20.0){
                Button(action: {
                    self.sign.loadPSBT()
                }) {
                    Text("Load PSBT")
                }
                .disabled(!self.defaults.hasCosigners || self.sign.psbt != nil)
                if self.sign.psbt != nil {
                    if self.sign.signed {
                        Text("Signed Transaction")
                    } else {
                        Text("Proposed Transaction")
                    }
                    if self.sign.destinations != nil {
                        ForEach(self.sign.destinations!.filter({ (dest) -> Bool in
                            return !dest.isChange;
                        })) { destination in
                            Text(destination.description).font(.system(.body, design: .monospaced))
                        }
                        Text("Fee: " + self.sign.fee)
                    }
                    Button(action: {
                        self.sign.signPSBT()
                    }) {
                        Text("Sign")
                    }
                    .disabled(!self.sign.canSign || self.sign.signed)
                    Button(action: {
                        self.sign.clearPSBT()
                    }) {
                        Text("Clear")
                    }
                }
            }
        }
    }
}
