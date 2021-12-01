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
        Text(messageText)
            .lineLimit(nil)
            .padding([.leading, .trailing])
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        SystemView(messageText: AttributedString("Top\nBottom", attributes: AttributeContainer([.strokeWidth: 3])))
    }
}
