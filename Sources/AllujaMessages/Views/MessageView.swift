//
//  MessageView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct MessageView<Message: MessageType>: View {
    let message: Message
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

fileprivate struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: MessagePreview())
    }
}
