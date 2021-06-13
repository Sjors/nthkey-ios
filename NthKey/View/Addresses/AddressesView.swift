//
//  AddressesView.swift
//  AddressesView
//
//  Created by Fathi on 10/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI
import CodeScanner

struct AddressesView: View {
    @ObservedObject var model: AddressesViewModel

    @State var showScanner: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 30.0) {
                HStack {
                    Spacer()
                    Button("Scan to check") {
                        showScanner.toggle()
                    }
                    .buttonStyle(LargeButtonStyle(backgroundColor: Color.clear,
                                                  foregroundColor: .primary,
                                                  isDisabled: false,
                                                  cornerRadius: 20))
                    Spacer()
                }
                .padding(.top)

                if model.items.count > 0 {
                    List {
                        ForEach(model.items) { item in
                            AddressView(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    model.toggleUsed(for: item)
                                }
                        }
                    }
                } else {
                    Text("Go to Settings to add cosigners")
                }
            }
            .navigationBarTitle("Address")
            .sheet(isPresented: $showScanner) {
                CodeScannerView(codeTypes: [.qr], completion: model.handleScan)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct AddressessView_Previews: PreviewProvider {
    static var previews: some View {
        let view = AddressesView(model: AddressesViewModel(dataManager: DataManager.preview))

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
    }
}
#endif
