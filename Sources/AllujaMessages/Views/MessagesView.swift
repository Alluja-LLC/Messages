//
//  MessagesView.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import SwiftUI

public struct MessagesView<Message: MessageType>: View {
    private let messages: [Message]

    @ObservedObject internal var context = MessagesViewContext()

    public init(withMessages messages: [Message]) {
        self.messages = messages

        self.context.messageEndsGroup = { message in
            let index = messages.firstIndex(of: message)!
            if index == messages.count - 1 {
                return true
            }

            // Split if last message was sent more than 5 minutes ago or the sender changes
            return message.timestamp.addingTimeInterval(5 * 60) < messages[index + 1].timestamp || message.sender.id != messages[index + 1].sender.id
        }
    }

    private var sortedMessages: [Message] {
        messages.sorted(by: { $0.timestamp < $1.timestamp })
    }

    private var groupedSortedMessages: [MessageGroup<Message>] {
        // Iterate over each message and see if the next one is last
        var completeGroups: [MessageGroup<Message>] = []
        var currentGroup: [Message] = []
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
        ScrollView {
            // If no grouping options enabled, just render normally
            if context.groupingOptions.isEmpty {
                ForEach(messages, id: \.id) { message in
                    MessageView(message: message)
                }
            } else { // Otherwise use grouped message renderer
                ForEach(groupedSortedMessages, id: \.id) { messageGroup in
                    GroupedMessageView(messageGroup: messageGroup, context: context)
                }
            }
        }
        .if(context.refreshAction != nil) {
            $0.refreshable(action: context.refreshAction!)
        }
        .imageViewScale(context.imageViewScale)
    }
}

private struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView<MessagePreview>(withMessages: [])
    }
}
