//
//  LargeButtonStyle.swift
//  LargeButtonStyle
//
//  Created by Sergey Vinogradov on 03.06.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct LargeButtonStyle: ButtonStyle {

    let backgroundColor: Color
    let foregroundColor: Color
    let isDisabled: Bool
    let cornerRadius: CGFloat

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? foregroundColor.opacity(0.3) : foregroundColor
        return configuration.label
            .padding()
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? backgroundColor.opacity(0.3) : backgroundColor)
            // This is the key part, we are using both an overlay as well as cornerRadius
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(currentForegroundColor, lineWidth: cornerRadius/10)
            )
            .font(Font.system(size: 25, weight: .bold))
    }
}

#if DEBUG
struct StrokedButton_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}, label: {
            Text("Button")

        })
        .buttonStyle(LargeButtonStyle(backgroundColor: Color.clear,
                                      foregroundColor: Color.red,
                                      isDisabled: true,
                                      cornerRadius: 20))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
