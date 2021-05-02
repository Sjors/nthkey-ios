//
//  SuggestionView.swift
//  SuggestionView
//
//  Created by Sergey Vinogradov on 02.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct SuggestionView: View {
    let text: String
    let onTap: (_ text: String) -> Void

    var body: some View {
        Text(text)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .foregroundColor(.white)
            .background(Color.gray)
            .clipShape(Capsule())
            .onTapGesture {
                onTap(text)
            }
    }
}

#if DEBUG
struct SuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        let view = SuggestionView(text: "Some text",
                       onTap: {text in print(text) })

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 150.0,
                              height: 200))
    }
}
#endif
