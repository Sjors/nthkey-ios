//
//  NetworkPickerView.swift
//  NetworkPickerView
//
//  Created by Sergey Vinogradov on 23.04.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct NetworkPickerView: View {
    @Binding var network: WalletNetwork

    private let networkTitles = WalletNetwork.allCases.map { $0.title }

    var body: some View {
        Picker(selection: $network, label: EmptyView()) {
            ForEach(WalletNetwork.allCases) { item in
                Text(item.title)
                    .tag(item)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

#if DEBUG
struct NetworkPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let view = NetworkPickerView(network: .constant(.mainnet))
            .previewLayout(.sizeThatFits)

        return Group {
            view

            view
                .preferredColorScheme(.dark)
        }
    }
}
#endif
