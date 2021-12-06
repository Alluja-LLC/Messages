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
    
    // Allows for Messages to keep track of timestamp view size and resize gestures accordingly
    @State private var messages: [MessageContainer<MessageT>]
    private let inputBar: () -> InputBarT
    
    @FocusState private var focusInput: Bool
    @State private var dragOffset: CGFloat = .zero

    @ObservedObject internal var context: MessagesViewContext<MessageT>

    public init(withMessages messages: [MessageT], @ViewBuilder withInputBar inputBar: @escaping () -> InputBarT) {
        self.inputBar = inputBar

        let context = MessagesViewContext<MessageT>()
        context.messageEndsGroup = { message in
            let index = messages.firstIndex(of: message)!
            if index == messages.count - 1 {
                return true
            }

            // Split if last message was sent more than 5 minutes ago or the sender changes
            return message.timestamp.addingTimeInterval(5 * 60) < messages[index + 1].timestamp || message.sender.id != messages[index + 1].sender.id
        }
        
        self.context = context
        
        // Iterate over each message and see if the next one is last
        var completeContainers: [MessageContainer<MessageT>] = []
        for (i, message) in messages.sorted(by: { $0.timestamp < $1.timestamp }).enumerated() {
            // Figure out what options are needed for each message
            var flags: [MessageGroupFlags] = []
            // If this is the first message OR the last message ends the group then add flag
            if completeContainers.isEmpty || completeContainers[completeContainers.index(before: i)].groupFlags.contains(.endGroup) {
                flags.append(.startGroup)
            }
            if context.messageEndsGroup(message) {
                flags.append(.endGroup)
            }
            if case .system(_) = message.kind {
                
            } else {
                if context.groupingOptions.contains(.collapseEnclosingViews) {
                    if flags.contains(.startGroup) {
                        flags.append(.renderHeader)
                    }
                    
                    if flags.contains(.endGroup) {
                        flags.append(.renderFooter)
                    }
                } else {
                    flags.append(contentsOf: [.renderHeader, .renderFooter])
                }
                
                if context.groupingOptions.contains(.collapseProfilePicture) {
                    if flags.contains(.endGroup) {
                        flags.append(.renderProfile)
                    } else {
                        flags.append(.renderClearProfile)
                    }
                } else {
                    flags.append(.renderProfile)
                }
            }
            completeContainers.append(.init(message: message, groupFlags: flags))
        }
        self._messages = State(initialValue: completeContainers)
    }
    
    private var maxTimestampViewWidth: CGFloat {
        messages.reduce(CGFloat.zero, { res, message in
            max(res, message.size.width)
        })
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { value in
                    List {
                        Group {
                            ForEach($messages, id: \.id) { $message in
                                MessageView(messageContainer: $message, context: context, timestampOffset: geometry.size.width)
                                    .padding([.top, .bottom], 2)
                                .contentShape(Rectangle())
                                .id(message.id)
                                .if(message.id == messages.last!.id) {
                                    // Temporary fix for ScrollView not scrolling to last message properly
                                    $0.padding(.bottom, 50)
                                }
                                .if(context.messageContextMenu != nil) {
                                    $0.contextMenu {
                                        context.messageContextMenu!(message.message)
                                    }
                                }
                            }
                        }
                        .padding([.leading, .trailing], 8)
                        .onAppear {
                            withAnimation {
                                value.scrollTo(messages.last?.id)
                            }
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                value.scrollTo(messages.last?.id)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .offset(x: dragOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1), value: dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 25.0)
                                .onChanged { value in
                                    dragOffset = max(min(value.translation.width, 0), -maxTimestampViewWidth)
                                }
                                .onEnded { _ in
                                    dragOffset = .zero
                                }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .messageWidth(geometry.size.width * 3 / 4)
                .if(refresh != nil) {
                    $0.refreshable {
                        await refresh!.callAsFunction()
                    }
                }
                .contentShape(Rectangle()) // Make sure hit testing covers entire area
                .if (focusInput) {
                    $0.onTapGesture {
                        focusInput = false
                    }
                }
                .imageViewScale(context.imageViewScale)
            }
            
            inputBar()
                .focused($focusInput)
        }
    }
}

fileprivate struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(withMessages: [MessagePreview](), withInputBar: {
            BasicInputBarView()
        })
    }
}
