//
//  MessagesView.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import SwiftUI

public struct MessagesView<MessageT: MessageType, InputBarT: View>: View {
    private let messages: [MessageT]
    private let inputBar: () -> InputBarT
    
    @FocusState private var focusInput: Bool

    @ObservedObject internal var context = MessagesViewContext()

    public init(withMessages messages: [MessageT], @ViewBuilder withInputBar inputBar: @escaping () -> InputBarT) {
        self.messages = messages
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

    private var sortedMessages: [MessageT] {
        messages.sorted(by: { $0.timestamp < $1.timestamp })
    }

    private var groupedSortedMessages: [MessageGroup<MessageT>] {
        // Iterate over each message and see if the next one is last
        var completeGroups: [MessageGroup<MessageT>] = []
        var currentGroup: [MessageT] = []
        for message in sortedMessages {
            currentGroup.append(message)
            if context.messageEndsGroup(message) {
                completeGroups.append(.init(messages: currentGroup))
                currentGroup.removeAll()
            }
        }

        // Get last group if needed
        completeGroups.append(.init(messages: currentGroup))
        return completeGroups
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    ScrollViewReader { value in
                        // If no grouping options enabled, just render normally
                        if context.groupingOptions.isEmpty {
                            ForEach(messages, id: \.id) { message in
                                MessageView(message: message, context: context)
                                    .id(message.id)
                                    .padding([.top, .bottom], 2)
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
                            .onChange(of: messages.count) { _ in
                                value.scrollTo(groupedSortedMessages.last?.id, anchor: .center)
                            }
                        }
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
            
            /*(.toolbar(content: {
                // Allows for a pseudo-inputAccesoryView by changing focus states and having a fake input bar copy
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        focusInput = true
                    }, label: {
                        inputBar()
                            .disabled(focusInput)
                    })
                    .buttonStyle(.plain)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    inputBar()
                        .focused($focusInput)
                }
            })*/
            
            inputBar()
                .focused($focusInput)
        }
    }
}

private struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(withMessages: [MessagePreview](), withInputBar: {
            BasicInputBarView()
        })
    }
}
