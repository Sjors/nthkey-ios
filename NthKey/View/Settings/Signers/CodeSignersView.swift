//
//  CodeSignersView.swift
//  CodeSignersView
//
//  Created by Fathi on 25/1/21.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct CodeSignersView: View {
    @ObservedObject var model: CodeSignersViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            if  model.hasOwnFingerprint {
                Text("Threshold: \(model.threshold) of \(model.items.count + 1)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("* \(model.ourFingerprintString)")
                    .font(.system(.body, design: .monospaced))
                    + Text(" (us)")
            }
            ForEach(model.items) { cosigner in
                CodeSignerView(item: cosigner)
            }
        }
    }
}

#if DEBUG
struct CodeSignersView_Previews: PreviewProvider {
    static var previews: some View {
        let view = CodeSignersView(model: (CodeSignersViewModel(dataManager: DataManager.preview)))

        return Group {
            view

            view
                .colorScheme(.dark)
                .background(Color.black)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
