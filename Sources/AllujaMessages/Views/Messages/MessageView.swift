//
//  MessageView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct MessageView<MessageT: MessageType, InputBarT: View>: View {
    let message: MessageT
    let context: MessagesView<MessageT, InputBarT>.MessagesViewContext

    var body: some View {
        HStack {
            if message.sender.position == .left {
                ProfilePictureView(forSender: message.sender)
            }
            
            AlignerView(alignment: message.sender.position) {
                VStack {
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
                    
                    switch message.kind {
                    case .text(let textItem):
                        TextView(forItem: textItem)
                    case .system(let strings):
                        SystemView(messageText: strings)
                    case .image(let imageItem):
                        ImageView(forItem: imageItem)
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
            }
            
            if message.sender.position == .right {
                ProfilePictureView(forSender: message.sender)
            }
        }
    }
}

private struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView<MessagePreview, EmptyView>(message: MessagePreview(), context: .init())
    }
}
