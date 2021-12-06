//
//  SystemView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

struct SystemView: View {
    let messageText: AttributedString

    var body: some View {
        HStack {
            Spacer()
            Text(messageText)
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.leading, .trailing])
            Spacer()
        }
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView(messageText: AttributedString("Top\nBottom", attributes: AttributeContainer([.strokeWidth: 3])))
    }
}
