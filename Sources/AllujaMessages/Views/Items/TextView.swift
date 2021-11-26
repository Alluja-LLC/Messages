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
        Text(item.text)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .padding(4)
            .background(RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundColor(item.backgroundColor))
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(forItem: TextPreview(isClient: false))
    }
}
