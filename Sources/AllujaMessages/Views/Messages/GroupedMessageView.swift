//
//  SwiftUIView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct GroupedMessageView<MessageT: MessageType>: View {
    @Environment(\.messageWidth) var width
    @Binding var messageGroup: MessageGroupContainer<MessageT>
    let context: MessagesViewContext<MessageT>
    let timestampOffset: CGFloat

    var shouldCollapseProfilePicture: Bool {
        context.groupingOptions.contains(.collapseProfilePicture)
    }

    var shouldCollapseEnclosing: Bool {
        context.groupingOptions.contains(.collapseEnclosingViews)
    }

    var body: some View {
        HStack {
            let lastMessagePosition = messageGroup.messages.last!.sender.position

            // Collapse profile pictures
            if lastMessagePosition == .left && shouldCollapseProfilePicture {
                ProfilePictureView(forSender: messageGroup.messages.last!.sender)
            }

            messageBody

            // Collapse profile pictures
            if lastMessagePosition == .right && shouldCollapseProfilePicture {
                ProfilePictureView(forSender: messageGroup.messages.last!.sender)
            }
        }
    }

    var messageBody: some View {
        VStack(spacing: 2) {
            // Collapsed header
            if let header = context.customHeader?(messageGroup.messages.first!), shouldCollapseEnclosing {
                let firstMessagePosition = messageGroup.messages.first!.sender.position

                HStack {
                    if firstMessagePosition == .right {
                        Spacer()
                    }

                    header
                        .fixedSize()

                    if firstMessagePosition == .left {
                        Spacer()
                    }
                }
                .padding([.leading, .trailing], 8)
            }

            ForEach(messageGroup.messages, id: \.id) { message in
                ZStack {
                    if let _ = context.groupingOptions.first(where: { item in
                        if case .collapseTimestamps(_) = item {
                            return true
                        }
                        return false
                    }) {
                        EmptyView()
                    } else {
                        HStack {
                            ChildSizeReader(size: $messageGroup.size) {
                                Text(context.defaultDateFormatter.string(from: messageGroup.messages.first!.timestamp))
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                                    .bold()
                                    .fixedSize()
                                    .padding([.top, .bottom, .trailing])
                                    .offset(x: timestampOffset)
                            }
                            Spacer()
                        }
                        .padding(.leading, 8)
                    }
                    
                    HStack {
                        if message.sender.position == .right {
                            Spacer()
                        }
                        
                        // Don't collapse profile pictures
                        if message.sender.position == .left && !shouldCollapseProfilePicture {
                            ProfilePictureView(forSender: messageGroup.messages.last!.sender)
                        }

                        VStack {
                            if let header = context.customHeader?(message), !shouldCollapseEnclosing {
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
                            
                            if let footer = context.customFooter?(message), !shouldCollapseEnclosing {
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

                        // Don't collapse profile pictures
                        if message.sender.position == .right && !shouldCollapseProfilePicture {
                            ProfilePictureView(forSender: messageGroup.messages.last!.sender)
                        }
                        
                        if message.sender.position == .left {
                            Spacer()
                        }
                    }
                }
            }

            // Collapsed footer
            if let footer = context.customFooter?(messageGroup.messages.last!), shouldCollapseEnclosing {
                let lastMessagePosition = messageGroup.messages.last!.sender.position
                
                HStack {
                    if lastMessagePosition == .right {
                        Spacer()
                    }
                    
                    footer
                    
                    if lastMessagePosition == .left {
                        Spacer()
                    }
                }
                .padding([.leading, .trailing], 8)
            }
        }
    }
}

private struct GroupedMessageView_Previews: PreviewProvider {
    static var previews: some View {
        GroupedMessageView<MessagePreview>(messageGroup: .constant(MessageGroupContainer<MessagePreview>(messages: [])), context: .init(), timestampOffset: 0)
    }
}
