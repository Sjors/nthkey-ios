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
    @Environment(\.colorScheme) var colorScheme

    private var selectionColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 30.0) {
                HStack {
                    Spacer()
                    Button("Scan to check") {
                        model.showScanner.toggle()
                    }
                    .buttonStyle(LargeButtonStyle(backgroundColor: Color.clear,
                                                  foregroundColor: .primary,
                                                  isDisabled: false,
                                                  cornerRadius: 20))
                    Spacer()
                }
                .padding(.top)

                if model.items.count > 0 {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(model.items, id: \.self.id) { item in
                                AddressView(item: item)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        model.toggleUsed(for: item)
                                    }
                                    .id(item.id)
                                    .listRowBackground(
                                        VStack {
                                            if model.addressToScroll == item.address {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selectionColor, lineWidth: 2)
                                                    .padding(2)
                                            }
                                        }
                                    )
                            }
                        }
                        .onChange(of: model.addressToScroll, perform: { value in
                            withAnimation {
                                proxy.scrollTo(value, anchor: .top)
                            }
                        })
                    }
                } else {
                    Text("Go to Settings to add cosigners")
                }
            }
            .navigationBarTitle("Address")
            .sheet(isPresented: $model.showScanner) {
                CodeScannerView(codeTypes: [.qr], completion: model.handleScan)
            }
            .alert(item: $model.scanQRError) { error in
                Alert(title: Text("Import PSBT error"),
                      message: Text(error.errorDescription ?? "Unknown error"),
                      dismissButton: .cancel())
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
