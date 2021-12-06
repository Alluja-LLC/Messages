//
//  MessageView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct MessageView<MessageT: MessageType>: View {
    
    @Environment(\.messageWidth) private var width
    @Binding var container: MessageContainer<MessageT>
    let context: MessagesViewContext<MessageT>
    let timestampOffset: CGFloat
    
    private var message: MessageT {
        container.message
    }
    
    private var messageShouldBeSpaced: Bool {
        if case .text = message.kind {
            return true
        } else if case .image = message.kind {
            return true
        }
        return false
    }
    
    private var groupPaddingEdges: Edge.Set {
        if context.groupingOptions.isEmpty {
            return []
        }
        var set = Edge.Set()
        if container.groupFlags.contains(.startGroup) {
            set.insert(.top)
        }
        if container.groupFlags.contains(.endGroup) {
            set.insert(.bottom)
        }
        return set
    }

    var body: some View {
        HStack {
            if let profile = context.customProfile?(message), message.sender.position == .left {
                profile
            }
                
            VStack(spacing: 2) {
                if let header = context.customHeader?(message), container.groupFlagsEmptyOrContains(.renderHeader) {
                    if case .system(_) = message.kind {
                        EmptyView()
                    } else {
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
                }
                    
                ZStack {
                    if container.timestampFlag != .hidden {
                        HStack {
                            ChildSizeReader(size: $container.size) {
                                VStack {
                                    if container.timestampFlag == .bottom {
                                        Spacer()
                                    }
                                    
                                    Text(context.defaultDateFormatter.string(from: message.timestamp))
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                        .bold()
                                        .fixedSize()
                                        .padding(.trailing)
                                        .offset(x: timestampOffset)
                                    
                                    if container.timestampFlag == .top {
                                        Spacer()
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    HStack {
                        if message.sender.position == .right && messageShouldBeSpaced {
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
                        
                        if message.sender.position == .left && messageShouldBeSpaced {
                            Spacer()
                        }
                    }
                }
                
                if let footer = context.customFooter?(message), container.groupFlagsEmptyOrContains(.renderFooter) {
                    if case .system(_) = message.kind {
                        EmptyView()
                    } else {
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
            .padding(groupPaddingEdges)
            
            if let profile = context.customProfile?(message), message.sender.position == .right {
                profile
            }
        }
    }
}

private struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView<MessagePreview>(container: .constant(MessageContainer<MessagePreview>(message: MessagePreview())), context: MessagesViewContext<MessagePreview>(messages: []), timestampOffset: 0)
    }
}
