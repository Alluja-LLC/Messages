//
//  TextView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

struct TextView: View {
    @Environment(\.messageCornerRadius) var cornerRadius
    let item: TextItem

    init(forItem item: TextItem) {
        self.item = item
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(item.backgroundColor)

            Text(item.text)
                .padding(2)
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(forItem: TextPreview(isClient: false))
    }
}
