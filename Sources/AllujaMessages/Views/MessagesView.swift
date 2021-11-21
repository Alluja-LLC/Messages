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
    }
    
    private var sortedMessages: [Message] {
        messages.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    private struct MessageGroup: Identifiable {
        let messages: [Message]
        
        let id = UUID()
    }
    
    private var groupedSortedMessages: [MessageGroup] {
        // Iterate over each message and see if the next one 
        []
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
                    
                }
            }
        }
        .if(context.refreshAction != nil) {
            $0.refreshable(action: context.refreshAction!)
        }
    }
}

internal struct MessagePreview: MessageType {
    var sender: SenderType? {
        nil
    }
    
    var id: String {
        "Hi"
    }
    
    var timestamp: Date {
        Date()
    }
    
    var kind: MessageKind {
        .text(AttributedString(""))
    }
    
    var customHeader: AnyView? {
        nil
    }
    
    var customFooter: AnyView? {
        nil
    }
}

internal struct SenderPreview: SenderType {
    var displayName: String {
        "Test Name"
    }
    
    var profileImageData: Data? {
        nil
    }
    
    var profileImageURL: URL? {
        nil
    }
    
    var id: String {
        "Test"
    }
    
    var isClient: Bool {
        false
    }
}

fileprivate struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView<MessagePreview>(withMessages: [])
    }
}
