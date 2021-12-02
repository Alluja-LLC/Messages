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
    @ObservedObject private var manager: MessagesViewManager<MessageT>
    @State private var messageContainers: [MessageContainer<MessageT>]
    @State private var messageGroupContainers: [MessageGroupContainer<MessageT>] = []
    private let inputBar: () -> InputBarT
    
    @FocusState private var focusInput: Bool
    @State private var dragOffset: CGFloat = .zero

    @ObservedObject internal var context: MessagesViewContext<MessageT>

    public init(withMessages messages: [MessageT], @ViewBuilder withInputBar inputBar: @escaping () -> InputBarT) {
        _messageContainers = State(initialValue: messages.map{ MessageContainer<MessageT>(message: $0) })
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
        
        //self._messageGroupContainers = State(initialValue: groupedSortedMessages)
        self.context = context
        self.manager = .init(messages: messages.map{ MessageContainer<MessageT>(message: $0) }, context: context)
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollViewReader { value in
                    List {
                        Group {
                            // If no grouping options enabled, just render normally
                            if context.groupingOptions.isEmpty {
                                ForEach($manager.messageContainers, id: \.id) { $message in
                                    ZStack {
                                        HStack {
                                            ChildSizeReader(size: $message.size) {
                                                MessageTimestampView(timestamp: message.message.timestamp, formatter: context.defaultDateFormatter)
                                                    .fixedSize()
                                                    .padding(.trailing)
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
                                    value.scrollTo(manager.messageContainers.last?.id, anchor: .bottom)
                                }
                                .onChange(of: manager.messageContainers.count) { newCount in
                                    value.scrollTo(manager.messageContainers.last?.id, anchor: .bottom)
                                }
                            } else { // Otherwise use grouped message renderer
                                ForEach($messageGroupContainers, id: \.id) { $messageGroup in
                                    ZStack {
                                        HStack {
                                            ChildSizeReader(size: $messageGroup.size) {
                                                MessageTimestampView(timestamp: messageGroup.messages.last!.timestamp, formatter: context.defaultDateFormatter)
                                                    .fixedSize()
                                                    .padding([.leading, .trailing])
                                                    .offset(x: geometry.size.width)
                                            }
                                            Spacer()
                                        }
                                        
                                        GroupedMessageView(messageGroup: messageGroup, context: context)
                                            .padding([.top, .bottom], 2)
                                    }
                                    .id(messageGroup.id)
                                }
                                .onAppear {
                                    value.scrollTo(manager.groupedSortedMessages.last?.id, anchor: .center)
                                }
                                .onChange(of: messageContainers.count) { _ in
                                    value.scrollTo(manager.groupedSortedMessages.last?.id, anchor: .center)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .offset(x: dragOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1), value: dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 25.0)
                                .onChanged { value in
                                    dragOffset = max(min(value.translation.width, 0), -manager.maxTimestampViewWidth)
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

fileprivate class MessagesViewManager<MessageT: MessageType>: ObservableObject {
    init(messages: [MessageContainer<MessageT>], context: MessagesViewContext<MessageT>) {
        messageContainers = messages.sorted(by: { $0.message.timestamp < $1.message.timestamp })
        self.context = context
    }
    
    @Published var messageContainers: [MessageContainer<MessageT>] = []
    @Published var messageGroupContainers: [MessageGroupContainer<MessageT>] = []
    let context: MessagesViewContext<MessageT>

    var groupedSortedMessages: [MessageGroupContainer<MessageT>] {
        // Iterate over each message and see if the next one is last
        var completeGroups: [MessageGroupContainer<MessageT>] = []
        var currentGroup: [MessageT] = []
        for message in messageContainers {
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
    
    var maxTimestampViewWidth: CGFloat {
        return messageContainers.reduce(CGFloat.zero, { res, message in
            return max(res, message.size.width)
        })
    }
}

fileprivate struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(withMessages: [MessagePreview](), withInputBar: {
            BasicInputBarView()
        })
    }
}
