//
//  ProductView.swift
//  ProductView
//
//  Created by Sergey Vinogradov on 19.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct ProductRowView: View {
    let title: String
    let details: String
    let price: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                Text(details)
                    .font(.subheadline)
            }
            Spacer()
            Text(price)
                .bold()
        }
        .padding()
    }
}

#if DEBUG
struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowView(title: "Monthly",
                    details: "Free trial for 3 days",
                    price: "$ 3.99")
    }
}
#endif
