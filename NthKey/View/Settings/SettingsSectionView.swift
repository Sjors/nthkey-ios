//
//  SettingsSectionView.swift
//  SettingsSectionView
//
//  Created by Sergey Vinogradov on 25.04.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()
            }
            content

            Divider()
        }
    }
}

#if DEBUG
struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let view = SettingsSectionView("Some header") {
            Text("Some long content")
                .foregroundColor(.red)
                .bold()
        }

        return Group {
            view

            NavigationView { view }
                .colorScheme(.dark)
        }

        .previewLayout(.fixed(width: 120, height: 250))
    }
}
#endif
