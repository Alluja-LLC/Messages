//
//  SwiftUIView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct GroupedMessageView<Message: MessageType>: View {
    let messageGroup: MessageGroup<Message>
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct GroupedMessageView_Previews: PreviewProvider {
    static var previews: some View {
        GroupedMessageView(messageGroup: MessageGroup<MessagePreview>(messages: []))
    }
}
