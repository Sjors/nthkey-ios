//
//  LoaderView.swift
//  LoaderView
//
//  Created by Sergey Vinogradov on 20.05.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct LoaderView<Content>: View where Content: View {
    let content: () -> Content

    @Environment(\.colorScheme) var colorScheme
    private var primaryColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        VStack {
            content()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .padding()
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color.secondary)
                .opacity(0.2)
                .shadow(radius: 10)
        )
    }
}

struct ToastView<Content>: View where Content: View {
    let content: () -> Content

    @Environment(\.colorScheme) var colorScheme
    private var primaryColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color.secondary)
                .opacity(0.6)
                .shadow(radius: 10)

            VStack {
                content()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .padding()
            }
        }
        .frame(width: 150, height: 150)
    }
}

extension View {
    func loaderOverlay() -> some View {
        LoaderView() { self }
    }

    func toast() -> some View {
        ToastView() { self }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        let view = Text("Some text")
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

        let both = VStack {
            view
                .loaderOverlay()

            view
                .toast()
        }

        return Group {
            both

            NavigationView { both }
                .colorScheme(.dark)
        }
    }
}
