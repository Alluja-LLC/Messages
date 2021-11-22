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
        Text("Hello, World!")
    }
}

fileprivate struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: MessagePreview())
    }
}
