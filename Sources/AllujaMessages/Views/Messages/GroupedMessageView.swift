//
//  SwiftUIView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct GroupedMessageView<MessageT: MessageType, InputBarT: View>: View {
    let messageGroup: MessageGroup<MessageT>
    let context: MessagesView<MessageT, InputBarT>.MessagesViewContext

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
        VStack {
            // Collapsed header
            if let header = messageGroup.messages.first!.customHeader, shouldCollapseEnclosing {
                let firstMessagePosition = messageGroup.messages.first!.sender.position

                AlignerView(alignment: firstMessagePosition) {
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
                }
            }

            ForEach(messageGroup.messages, id: \.id) { message in
                HStack {
                    // Don't collapse profile pictures
                    if message.sender.position == .left && !shouldCollapseProfilePicture {
                        ProfilePictureView(forSender: messageGroup.messages.last!.sender)
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

                    // Don't collapse profile pictures
                    if message.sender.position == .right && !shouldCollapseProfilePicture {
                        ProfilePictureView(forSender: messageGroup.messages.last!.sender)
                    }
                }
            }

            // Collapsed footer
            if let footer = messageGroup.messages.last!.customFooter, shouldCollapseEnclosing {
                let lastMessagePosition = messageGroup.messages.last!.sender.position

                AlignerView(alignment: lastMessagePosition) {
                    HStack {
                        if lastMessagePosition == .right {
                            Spacer()
                        }

                        footer
                            .fixedSize()

                        if lastMessagePosition == .left {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

private struct GroupedMessageView_Previews: PreviewProvider {
    static var previews: some View {
        GroupedMessageView<MessagePreview, EmptyView>(messageGroup: MessageGroup<MessagePreview>(messages: []), context: .init())
    }
}
