//
//  CodeSignerView.swift
//  CodeSignerView
//
//  Created by Sergey Vinogradov on 28.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import SwiftUI

struct CodeSignerView: View {
    var item: CosignerEntity

    var body: some View {
        Text("* \( item.fingerprint?.hexString ?? "N/A" )" )
            .font(.system(.body, design: .monospaced))
            + Text(" (\(item.name ?? ""))")
    }
}

#if DEBUG
import CoreData

struct CodeSignerView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistentStore.preview.container.viewContext
        let request = NSFetchRequest<CosignerEntity>(entityName: "CosignerEntity")

        return Group {
            if let items = try? context.fetch(request) {
                let view = List {
                    ForEach(items) { item in
                        CodeSignerView(item: item)
                    }
                }
                Group {
                    view
                    
                    view
                        .colorScheme(.dark)
                }
                .previewLayout(.fixed(width: 350, height: 100))
            } else {
                Text("Can't find mock to display")
            }
        }
    }
}
#endif
