//
//  MessagesView.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import SwiftUI

fileprivate struct MessageContainer<MessageT: MessageType> {
    let message: MessageT
    var id: String {
        message.id
    }
    var size: CGSize = .zero
}

public struct MessagesView<MessageT: MessageType, InputBarT: View>: View {
    // Allows for Messages to keep track of timestamp view size and resize gestures accordingly
    @State private var messageContainers: [MessageContainer<MessageT>]
    private let inputBar: () -> InputBarT
    
    @FocusState private var focusInput: Bool
    @State private var dragOffset: CGFloat = .zero

    @ObservedObject internal var context = MessagesViewContext()

    public init(withMessages messages: [MessageT], @ViewBuilder withInputBar inputBar: @escaping () -> InputBarT) {
        self._messageContainers = State(initialValue: messages.map{ MessageContainer(message: $0) })
        self.inputBar = inputBar

        self.context.messageEndsGroup = { message in
            let index = messages.firstIndex(of: message)!
            if index == messages.count - 1 {
                return true
            }

            // Split if last message was sent more than 5 minutes ago or the sender changes
            return message.timestamp.addingTimeInterval(5 * 60) < messages[index + 1].timestamp || message.sender.id != messages[index + 1].sender.id
        }
    }

    private var sortedMessages: [MessageContainer<MessageT>] {
        messageContainers.sorted(by: { $0.message.timestamp < $1.message.timestamp })
    }

    private var groupedSortedMessages: [MessageGroup<MessageT>] {
        // Iterate over each message and see if the next one is last
        var completeGroups: [MessageGroup<MessageT>] = []
        var currentGroup: [MessageT] = []
        for message in sortedMessages {
            currentGroup.append(message.message)
            if context.messageEndsGroup(message.message) {
                completeGroups.append(.init(messages: currentGroup))
                currentGroup.removeAll()
            }
        }

        // Get last group if needed
        completeGroups.append(.init(messages: currentGroup))
        return completeGroups
    }
    
    private var maxTimestampViewWidth: CGFloat {
        return messageContainers.reduce(CGFloat.zero, { res, message in
            return max(res, message.size.width)
        })
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { value in
                        Group {
                        // If no grouping options enabled, just render normally
                        if context.groupingOptions.isEmpty {
                            ForEach($messageContainers, id: \.id) { $message in
                                ZStack {
                                    HStack {
                                        ChildSizeReader(size: $message.size) {
                                            MessageTimestampView(timestamp: message.message.timestamp, formatter: context.defaultDateFormatter)
                                                .fixedSize()
                                                .padding([.leading, .trailing])
                                                .offset(x: geometry.size.width)
                                        }
                                        Spacer()
                                    }
                                    
                                    MessageView(message: message.message, context: context)
                                        .padding([.top, .bottom], 2)
                                }
                                .id(message.id)
                            }
                            .onAppear {
                                value.scrollTo(sortedMessages.last?.id, anchor: .center)
                            }
                            .onChange(of: sortedMessages.count) { newCount in
                                guard newCount > 0 else { return }
                                value.scrollTo(sortedMessages.last!.id, anchor: .center)
                            }
                        } else { // Otherwise use grouped message renderer
                            ForEach(groupedSortedMessages, id: \.id) { messageGroup in
                                GroupedMessageView(messageGroup: messageGroup, context: context)
                            }
                            .onAppear {
                                value.scrollTo(groupedSortedMessages.last?.id, anchor: .center)
                            }
                            .onChange(of: messageContainers.count) { _ in
                                value.scrollTo(groupedSortedMessages.last?.id, anchor: .center)
                            }
                        }
                        }.offset(x: dragOffset)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1), value: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = max(min(value.translation.width, 0), -maxTimestampViewWidth)
                                    }
                                    .onEnded { _ in
                                        dragOffset = .zero
                                    }
                            )
                    }
                }
                .messageWidth(geometry.size.width * 3 / 4)
                .if(context.refreshAction != nil) {
                    $0.refreshable(action: context.refreshAction!)
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

private struct TimestampHelperView: View {
    let timestamp: Date
    let formatter: DateFormatter
    
    @State private var size: CGSize = .zero
    var body: some View {
        EmptyView()
    }
}

private struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(withMessages: [MessagePreview](), withInputBar: {
            BasicInputBarView()
        })
    }
}
