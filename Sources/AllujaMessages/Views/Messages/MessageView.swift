//
//  MessageView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct MessageView<MessageT: MessageType>: View {
    @Environment(\.messageWidth) private var width
    @Binding var messageContainer: MessageContainer<MessageT>
    let context: MessagesViewContext<MessageT>
    let timestampOffset: CGFloat
    
    private var message: MessageT {
        messageContainer.message
    }

    var body: some View {
        HStack {
            if message.sender.position == .left {
                ProfilePictureView(forSender: message.sender)
            }
                
            VStack(spacing: 2) {
                if let header = context.customHeader?(message) {
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
                    
                ZStack {
                    HStack {
                        ChildSizeReader(size: $messageContainer.size) {
                            Text(context.defaultDateFormatter.string(from: message.timestamp))
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .bold()
                                .fixedSize()
                                .padding(.trailing)
                                .offset(x: timestampOffset)
                        }
                        Spacer()
                    }
                    .padding(message.sender.position == .right ? [.leading] : [], 8)
                    
                    HStack {
                        if message.sender.position == .right {
                            Spacer()
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
                        
                        if message.sender.position == .left {
                            Spacer()
                        }
                    }
                }
                
                if let footer = context.customFooter?(message) {
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
        MessageView<MessagePreview>(messageContainer: .constant(MessageContainer<MessagePreview>(message: MessagePreview())), context: MessagesViewContext<MessagePreview>(), timestampOffset: 0)
    }
}
