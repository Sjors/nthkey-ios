//
//  SubscriptionView.swift
//  SubscriptionView
//
//  Created by Sergey Vinogradov on 03.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct SubscriptionView: View {
    @ObservedObject var model: SubscriptionViewModel

    @Environment(\.colorScheme) var colorScheme

    let closeBlock: () -> Void

    private var selectionColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        let contentView = VStack {
            Text("Use real Bitcoin (mainnet)")
                .font(.title)

            ForEach(0 ..< model.productTitles.count, id:\.self) { idx in
                Group {
                    if idx == model.currentProductIndex {
                        ProductView(idx)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectionColor, lineWidth: 2)
                            )
                    } else {
                        ProductView(idx)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    model.currentProductIndex = idx
                }
            }
            .padding()

            Button(action: {
                model.purchaseCurrentProduct()
            }, label: {
                Text("Subscribe Now")
                    .bold()
                    .font(.title)
                    .foregroundColor(selectionColor)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectionColor, lineWidth: 2)
                    )
            })

            Button(action: {
                model.restorePurchases()
            }, label: {
                Text("Restore purchases")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            })
        }

        return NavigationView {
            Group {
                switch model.state {
                case .initial:
                    Text("Connecting to App Store")
                        .loaderOverlay()
                case .ready:
                    contentView
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: closeBlock,
                           label: { Text("Close") })
                }
            }
        }
    }

    fileprivate func ProductView(_ idx: Int) -> some View {
        ProductRowView(title: model.productTitles[idx],
                       details: model.productDescriptions[idx],
                       price: model.productPrices[idx])
    }
}

#if DEBUG
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            ProductRowView(title: "Monthly",
                           details: "Free trial for 3 days",
                           price: "$ 3.99")
            SubscriptionView(model: SubscriptionViewModel(subsManager: SubscriptionManager.mock),
                             closeBlock: {})

            SubscriptionView(model: SubscriptionViewModel.readyToPurchaseMock,
                             closeBlock: {})
        }

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
