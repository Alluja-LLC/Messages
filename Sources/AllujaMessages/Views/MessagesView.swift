//
//  MessagesView.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import SwiftUI

public struct MessagesView<MessageT: MessageType, InputBarT: View>: View {
    // Automatically forward native refreshable modifier
    @Environment(\.refresh) var refresh

    private let inputBar: () -> InputBarT

    @FocusState private var focusInput: Bool
    @State private var dragOffset: CGFloat = .zero
    @State private var maxOffset: CGSize = .zero

    // Holds all message data
    @ObservedObject internal var context = MessagesViewContext<MessageT>()
    
    let messages: [MessageT]
    
    var containerizedMessages: [MessageContainer<MessageT>] {
        // Iterate over each message and see if the next one is last
        var completeContainers: [MessageContainer<MessageT>] = []
        // Whether or not to attempt to place a footer on the next iteration
        var footerFallthrough: Bool = false
        for (i, message) in messages.sorted(by: { $0.timestamp < $1.timestamp }).enumerated() {
            // Figure out what options are needed for each message
            var flags: Set<MessageGroupFlag> = []
            var timestampFlag: MessageGroupTimestampFlag = .hidden

            // If this is the first message OR the last message ends the group then add flag
            if completeContainers.isEmpty || completeContainers[completeContainers.index(before: i)].groupFlags.contains(.endGroup) {
                if case .collapseTimestamps(let anchor) = context.groupingOptions.first(where: { item in
                    if case .collapseTimestamps(_) = item {
                        return true
                    }
                    return false
                }), anchor == .top {
                    timestampFlag = .top
                }

                flags.insert(.startGroup)
            }

            if context.messageEndsGroup(message) {
                if case .collapseTimestamps(let anchor) = context.groupingOptions.first(where: { item in
                    if case .collapseTimestamps(_) = item {
                        return true
                    }
                    return false
                }), anchor == .bottom {
                    timestampFlag = .bottom
                }

                flags.insert(.endGroup)
            }

            // If there aren't any timestamp grouping options, then display timestamp normally
            if case .collapseTimestamps(_) = context.groupingOptions.first(where: { item in
                if case .collapseTimestamps(_) = item {
                    return true
                }
                return false
            }) {

            } else {
                timestampFlag = .normal
            }

            switch message.kind {
            case .system(_):
                if flags.contains(.endGroup) && !flags.contains(.startGroup) && i != messages.startIndex {
                    completeContainers[completeContainers.index(before: completeContainers.endIndex)].groupFlags.insert(.renderFooter)
                } else if flags.contains(.startGroup) && !flags.contains(.endGroup) {
                    footerFallthrough = true
                }
            default:
                if context.groupingOptions.contains(.collapseEnclosingViews) {
                    if flags.contains(.startGroup) {
                        flags.insert(.renderHeader)
                    }

                    if flags.contains(.endGroup) || footerFallthrough {
                        flags.insert(.renderFooter)
                        footerFallthrough = false
                    }
                } else {
                    flags.insert(.renderHeader)
                    flags.insert(.renderFooter)
                }

                if context.groupingOptions.contains(.collapseProfilePicture) {
                    if flags.contains(.endGroup) {
                        flags.insert(.renderProfile)
                    } else {
                        flags.insert(.renderClearProfile)
                    }
                } else {
                    flags.insert(.renderProfile)
                }
            }
            completeContainers.append(.init(message: message, groupFlags: flags, timestampFlag: timestampFlag))
        }

        return completeContainers
    }

    public init(withMessages messages: [MessageT], @ViewBuilder withInputBar inputBar: @escaping () -> InputBarT) {
        self.inputBar = inputBar
        self.messages = messages

        context.messageEndsGroup = { message in
            let index = messages.firstIndex(of: message)!
            if index == messages.count - 1 {
                return true
            }

            // Split if last message was sent more than 5 minutes ago or the sender changes
            return message.timestamp.addingTimeInterval(5 * 60) < messages[index + 1].timestamp || message.alignment != messages[index + 1].alignment
        }

        self.context = context
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Somewhat hacky way to get the max text width from the timestamp formatter without taking up a ton of memory
            ChildSizeReader(size: $maxOffset) {
                ZStack {
                    ForEach(containerizedMessages, id: \.id) { message in
                        Text(context.messageTimestampFormatter.string(from: message.message.timestamp))
                    }
                }
            }
            .opacity(0)
            .frame(height: 0)

            GeometryReader { geometry in
                ScrollViewReader { value in
                    if #available(iOS 16, *) {
                        ScrollView {
                            inner(geometry: geometry, value: value)
                        }
                    } else {
                        List {
                            inner(geometry: geometry, value: value)
                        }
                    }
                    
                }
                .listStyle(PlainListStyle())
                .messageCornerRadius(context.messageCornerRadius)
                .messageWidth(context.messageMaxWidth(geometry))
                .if(refresh != nil) {
                    $0.refreshable {
                        await refresh!.callAsFunction()
                    }
                }
                .contentShape(Rectangle()) // Make sure hit testing covers entire area
                .if(focusInput) {
                    $0.onTapGesture {
                        focusInput = false
                    }
                }
            }

            inputBar()
                .focused($focusInput)
        }
    }
    
    private func inner(geometry: GeometryProxy, value: ScrollViewProxy) -> some View {
        Group {
            ForEach(containerizedMessages, id: \.id) { message in
                MessageView(container: message, context: context, timestampOffset: geometry.size.width)
                    .padding([.top, .bottom], 2)
                    .contentShape(Rectangle())
                    .if(context.messageContextMenu != nil) {
                        $0.contextMenu {
                            context.messageContextMenu!(message.message)
                        }
                    }
                    .id(message.id)
            }
        }
        .padding([.leading, .trailing], 8)
        .onAppear {
            context.proxyOnAppear?(value)
        }
        .onChange(of: messages) { messages in
            context.proxyOnMessagesChange?(value, messages)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .offset(x: dragOffset)
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1), value: dragOffset)
        .if(context.showTimestampsOnSwipe) {
            $0.gesture(
                DragGesture(minimumDistance: 25.0)
                    .onChanged { value in
                        dragOffset = max(min(value.translation.width, 0), -maxOffset.width)
                    }
                    .onEnded { _ in
                        dragOffset = .zero
                    }
            )
        }
    }
}

private struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(withMessages: [MessagePreview](), withInputBar: {
            BasicInputBarView(message: .constant("Hi"), onSend: {})
        })
    }
}
