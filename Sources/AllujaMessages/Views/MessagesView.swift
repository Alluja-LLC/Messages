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
        self.manager = .init(messages: messages.map{ MessageContainer<MessageT>(message: $0) }, context: context)
    }

    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollViewReader { value in
                    List {
                        Group {
                            // If no grouping options enabled, just render normally
                            if context.groupingOptions.isEmpty {
                                ForEach($manager.messageContainers, id: \.id) { $message in
                                    Menu(content: { context.messageContextMenu!(message.message) }, label: {
                                        MessageView(messageContainer: $message, context: context, timestampOffset: geometry.size.width)
                                            .padding([.top, .bottom], 2)
                                        .contentShape(Rectangle())
                                        .id(message.id)
                                        .if(message.id == manager.messageContainers.last!.id) {
                                            // Temporary fix for ScrollView not scrolling to last message properly
                                            $0.padding(.bottom, 50)
                                        }
                                    })
                                }
                            } else { // Otherwise use grouped message renderer
                                ForEach($manager.messageGroupContainers, id: \.id) { $messageGroup in
                                    ZStack {
                                        // Controls how timestamps are rendered
                                        if let anchor = context.groupingOptions.first(where: { item in
                                            if case .collapseTimestamps(_) = item {
                                                return true
                                            }
                                            return false
                                        }) {
                                            HStack {
                                                ChildSizeReader(size: $messageGroup.size) {
                                                    VStack {
                                                        if case .collapseTimestamps(let position) = anchor, case .bottom = position {
                                                            Spacer()
                                                                .padding(.top)
                                                            
                                                            Text(context.defaultDateFormatter.string(from: messageGroup.messages.last!.timestamp))
                                                                .foregroundColor(.secondary)
                                                                .font(.footnote)
                                                                .bold()
                                                                .fixedSize()
                                                                .padding([.top, .bottom, .trailing])
                                                                .offset(x: geometry.size.width)
                                                        }
                                                        
                                                        if case .collapseTimestamps(let position) = anchor, case .top = position {
                                                            Text(context.defaultDateFormatter.string(from: messageGroup.messages.first!.timestamp))
                                                                .foregroundColor(.secondary)
                                                                .font(.footnote)
                                                                .bold()
                                                                .fixedSize()
                                                                .padding([.top, .bottom, .trailing])
                                                                .offset(x: geometry.size.width)
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.leading, 8)
                                        }
                                        
                                        GroupedMessageView(messageGroup: $messageGroup, context: context, timestampOffset: geometry.size.width)
                                            .padding([.top, .bottom], 2)
                                    }
                                    
                                    EmptyView()
                                    .id(messageGroup.id)
                                    .if(messageGroup.id == manager.messageGroupContainers.last!.id) {
                                        // Temporary fix for ScrollView not scrolling to last message properly
                                        $0.padding(.bottom, 50)
                                    }
                                }
                                
                            }
                        }
                        .onAppear {
                            withAnimation {
                                if context.groupingOptions.isEmpty {
                                    value.scrollTo(manager.messageContainers.last?.id)
                                } else {
                                    value.scrollTo(manager.messageGroupContainers.last?.id)
                                }
                            }
                        }
                        .onChange(of: manager.messageContainers.count) { _ in
                            withAnimation {
                                if context.groupingOptions.isEmpty {
                                    value.scrollTo(manager.messageContainers.last?.id)
                                } else {
                                    value.scrollTo(manager.messageGroupContainers.last?.id)
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
                                    dragOffset = max(min(value.translation.width, 0), -max(manager.maxTimestampViewWidth, manager.maxGroupedTimestampViewWidth))
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
        // Iterate over each message and see if the next one is last
        var completeGroups: [MessageGroupContainer<MessageT>] = []
        var currentGroup: [MessageT] = []
        for message in messages.sorted(by: { $0.message.timestamp < $1.message.timestamp }) {
            currentGroup.append(message.message)
            if context.messageEndsGroup(message.message) {
                completeGroups.append(.init(messages: currentGroup))
                currentGroup.removeAll()
            }
        }

        // Get last group if needed
        if !currentGroup.isEmpty {
            completeGroups.append(.init(messages: currentGroup))
        }
        messageGroupContainers = completeGroups
        
        messageContainers = messages.sorted(by: { $0.message.timestamp < $1.message.timestamp })
    }
    
    @Published var messageContainers: [MessageContainer<MessageT>]
    // No need to Publish since messageContainers is always updated when this is
    var messageGroupContainers: [MessageGroupContainer<MessageT>]
    
    var maxTimestampViewWidth: CGFloat {
        messageContainers.reduce(CGFloat.zero, { res, message in
            max(res, message.size.width)
        })
    }
    
    var maxGroupedTimestampViewWidth: CGFloat {
        messageGroupContainers.reduce(CGFloat.zero, { res, message in
            max(res, message.size.width)
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
