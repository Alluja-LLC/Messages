//
//  MessageView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct MessageView<MessageT: MessageType>: View {
    @Environment(\.messageWidth) var width
    let message: MessageT
    let context: MessagesViewContext<MessageT>

    var body: some View {
        HStack {
            if message.sender.position == .left {
                ProfilePictureView(forSender: message.sender)
            }
            
            VStack(alignment: message.sender.position == .left ? .leading : .trailing, spacing: 2) {
                if let header = message.customHeader {
                    HStack {
                        if message.sender.position == .right {
                            Spacer()
                        }
                        
                        header
                        
                        if message.sender.position == .left {
                            Spacer()
                        }
                    }
                }
                
                let messageAlignment: Alignment = message.sender.position == .left ? .leading : .trailing
                switch message.kind {
                case .text(let textItem):
                    TextView(forItem: textItem)
                        .frame(width: width, alignment: messageAlignment)
                case .system(let string):
                    SystemView(messageText: string)
                case .image(let imageItem):
                    ImageView(forItem: imageItem)
                        .frame(width: width, alignment: messageAlignment)
                case .custom(let customItem):
                    if let renderer = context.customRenderer(forID: customItem.id) {
                        renderer(message)
                    } else {
                        Text("No Renderer Found for ID \(customItem.id) :(")
                    }
                }
                
                if let footer = message.customFooter {
                    HStack {
                        if message.sender.position == .right {
                            Spacer()
                        }
                        
                        footer
                        
                        if message.sender.position == .left {
                            Spacer()
                        }
                    }
                }
            }
            
            if message.sender.position == .right {
                ProfilePictureView(forSender: message.sender)
            }
        }
    }
}

private struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView<MessagePreview>(message: MessagePreview(), context: MessagesViewContext<MessagePreview>())
    }
}
