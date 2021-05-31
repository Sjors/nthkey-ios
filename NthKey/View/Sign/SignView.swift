//
//  SignView.swift
//  SignView
//
//  Created by Sjors Provoost on 20/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import CodeScanner

struct SignView : View {
    @ObservedObject var model: SignViewModel

    var contentView: AnyView {
        switch model.state {
        case .initial:
            return Text("Please select the wallet on settings")
                .toAnyView
        case .canLoad:
            return VStack(alignment: .leading, spacing: 20.0) {
                Button("Scan PSBT") {
                    model.openScanner()
                }
                .disabled(model.needSubscription)

                Button("Load PSBT") {
                    model.loadFile()
                }
                .disabled(model.needSubscription)

                if model.needSubscription {
                    Button(action: {
                        model.openSubscriptions()
                    }, label: {
                        Text("A subscription is required to sign with this wallet")
                            .underline()
                    })
                }
            }.toAnyView
        case .loaded, .canSign, .signed:
            return ScrollView {
                VStack(alignment: .leading, spacing: 20.0){
                    HStack {
                        if model.state == .signed {
                            Text("Signed Transaction")
                        } else {
                            Text("Proposed Transaction")
                        }
                        Spacer()
                    }

                    ForEach(model.destinations.filter({ dest -> Bool in
                        // Hide change address, except if it's the only destination
                        return !dest.isChange || model.destinations.count == 1;
                    })) { destination in
                        Text(destination.description)
                            .font(.system(.body, design: .monospaced))
                    }
                    Text(model.feeString)

                    Button("Sign") {
                        model.sign()
                    }
                    .disabled(model.state != .canSign)

                    if model.state == .signed {
                        Image(uiImage: model.psbtSignedImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 350, height: 350)

                        Button("Save") {
                            model.saveFile()
                        }

                        Button("Copy") {
                            model.copyToClipboard()
                        }
                    }

                    Button("Clear") {
                        model.clear()
                    }
                    .padding(.bottom, 50)
                }
            }
            .toAnyView
        }
    }

    var body: some View {
        contentView
            .padding(.horizontal)
            .sheet(item: $model.activeSheet) { value in
                switch value {
                    case .scanner:
                        CodeScannerView(codeTypes: [.qr], completion: model.handleScan)
                    case .subscription:
                        SubscriptionView(model: model.subsViewModel,
                                         closeBlock: { model.activeSheet = nil })
                }
            }
            .alert(item: $model.errorMessage) { error in
                Alert(title: Text("Error"),
                      message: Text(error),
                      dismissButton: .default(Text("Ok"), action: {
                        model.clear()
                      }))
            }
    }
}

#if DEBUG
struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        let view = List {
            Section(header: Text("Initial. Wallet isn't selected")) {
                SignView(model: SignViewModel.mocks.unselected)
            }
            Section(header: Text("Can scan or load")) {
                SignView(model: SignViewModel.mocks.canLoad)
            }
            Section(header: Text("Loaded, but can't sign")) {
                SignView(model: SignViewModel.mocks.loaded)
            }
            Section(header: Text("Loaded, can sign")) {
                SignView(model: SignViewModel.mocks.canSign)
            }
            Section(header: Text("Signed")) {
                SignView(model: SignViewModel.mocks.signed)
            }
        }

        return Group {
            view

            view
                .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 400, height: 1250))
    }
}
#endif
