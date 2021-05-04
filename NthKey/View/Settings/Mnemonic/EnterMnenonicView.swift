//
//  EnterMnenonicView.swift
//  EnterMnenonicView
//
//  Created by Sergey Vinogradov on 02.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct EnterMnenonicView: View {
    @ObservedObject var model: EnterMnenonicViewModel

    @Binding var hasSeed: Bool

    var body: some View {
        VStack {
            TextField("battery staple horse...",
                      text: $model.mnemonicText)
                .keyboardType(.alphabet)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)

            ScrollView(.horizontal, showsIndicators: true, content: {
                HStack {
                    ForEach(model.suggestions, id: \.self) { item in
                        SuggestionView(text: item, onTap: { text in
                            model.changeCurrentStringWith(text)
                        })
                    }
                }
            })

            Button("OK") {
                model.applyEntropy()
                hasSeed = true
            }
            .disabled(!model.validMnemonic)
        }
    }
}

#if DEBUG
struct EnterMnenonicView_Previews: PreviewProvider {
    static var previews: some View {
        let view = EnterMnenonicView(model: EnterMnenonicViewModel(),
                                     hasSeed: .constant(false))
            .padding()

        return Group {
            view
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
