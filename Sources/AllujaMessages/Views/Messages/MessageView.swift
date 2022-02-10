//
//  MessageView.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import SwiftUI

internal struct MessageView<MessageT: MessageType>: View {
    @Environment(\.messageWidth) private var width
    @Environment(\.messageCornerRadius) private var cornerRadius
    let container: MessageContainer<MessageT>
    let context: MessagesViewContext<MessageT>
    let timestampOffset: CGFloat

    @State private var avatarSize: CGSize = .zero

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
        VStack(spacing: 2) {
            if let header = context.header?(message), container.groupFlagsEmptyOrContains(.renderHeader) {
                if case .system(_) = message.kind {
                    EmptyView()
                } else {
                    HStack {
                        if message.alignment == .right {
                            Spacer()
                        }

                        header
                            .padding(message.alignment == .right ? .trailing : .leading, avatarSize.width + 4)

                        if message.alignment == .left {
                            Spacer()
                        }
                    }
                }
            }

            ZStack {
                if container.timestampFlag != .hidden {
                    HStack {
                            VStack {
                                if container.timestampFlag == .bottom {
                                    Spacer()
                                }
                                
                                Text(context.messageTimestampFormatter.string(from: message.timestamp))
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
                        Spacer()
                    }
                }

                HStack(alignment: .bottom, spacing: 4) {
                    switch message.kind {
                    case .system(_):
                        EmptyView()
                    default:
                        if let profile = context.avatar?(message), message.alignment == .left && (container.groupFlagsEmptyOrContains(.renderProfile) || container.groupFlagsEmptyOrContains(.renderClearProfile)) {
                            ChildSizeReader(size: $avatarSize) {
                                profile
                            }
                            .opacity(container.groupFlagsEmptyOrContains(.renderProfile) ? 100 : 0)
                        }
                    }

                    if message.alignment == .right && messageShouldBeSpaced {
                        Spacer()
                    }

                    let messageAlignment: Alignment = message.alignment == .left ? .leading : .trailing
                    switch message.kind {
                    case .text(let textItem):
                        TextView(forItem: textItem)
                            .frame(width: width, alignment: messageAlignment)
                    case .system(let string):
                        SystemView(messageText: string)
                    case .image(_):
                        ImageView(forMessage: message, withContext: context)
                            .frame(width: width, alignment: messageAlignment)
                    case .custom(let customItem):
                        if let renderer = context.customRenderer(forID: customItem.id) {
                            renderer(message, CustomRendererInfo(width: width, cornerRadius: cornerRadius))
                        } else {
                            Text("No Renderer Found for ID \(customItem.id) :(")
                        }
                    }

                    if message.alignment == .left && messageShouldBeSpaced {
                        Spacer()
                    }

                    switch message.kind {
                    case .system(_):
                        EmptyView()
                    default:
                        if let profile = context.avatar?(message), message.alignment == .right && (container.groupFlagsEmptyOrContains(.renderProfile) || container.groupFlagsEmptyOrContains(.renderClearProfile)) {
                            ChildSizeReader(size: $avatarSize) {
                                profile
                            }
                            .opacity(container.groupFlagsEmptyOrContains(.renderProfile) ? 100 : 0)
                        }
                    }
                }
            }

            if let footer = context.footer?(message), container.groupFlagsEmptyOrContains(.renderFooter) {
                if case .system(_) = message.kind {
                    EmptyView()
                } else {
                    HStack {
                        if message.alignment == .right {
                            Spacer()
                        }

                        footer
                            .padding(message.alignment == .right ? .trailing : .leading, avatarSize.width + 4)

                        if message.alignment == .left {
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(groupPaddingEdges)
    }
}

private struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView<MessagePreview>(container: MessageContainer<MessagePreview>(message: MessagePreview()), context: MessagesViewContext<MessagePreview>(), timestampOffset: 0)
    }
}
