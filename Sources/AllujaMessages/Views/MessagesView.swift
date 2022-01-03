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

    // Holds all message data
    @ObservedObject internal var context: MessagesViewContext<MessageT>

    public init(withMessages messages: [MessageT], @ViewBuilder withInputBar inputBar: @escaping () -> InputBarT) {
        self.inputBar = inputBar

        let context = MessagesViewContext<MessageT>(messages: messages)
        context.messageEndsGroup = { message in
            let index = messages.firstIndex(of: message)!
            if index == messages.count - 1 {
                return true
            }

            // Split if last message was sent more than 5 minutes ago or the sender changes
            return message.timestamp.addingTimeInterval(5 * 60) < messages[index + 1].timestamp
        }

        self.context = context
    }

    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollViewReader { value in
                    List {
                        Group {
                            ForEach($context.messages, id: \.id) { $message in
                                MessageView(container: $message, context: context, timestampOffset: geometry.size.width)
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
                        .onChange(of: context.messages) { messages in
                            context.proxyOnMessagesChange?(value, messages.map{ $0.message })
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .offset(x: dragOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1), value: dragOffset)
                        .if(context.showTimestampsOnSwipe) {
                            $0.gesture(
                                DragGesture(minimumDistance: 25.0)
                                    .onChanged { value in
                                        dragOffset = max(min(value.translation.width, 0), -context.maxTimestampViewWidth)
                                    }
                                    .onEnded { _ in
                                        dragOffset = .zero
                                    }
                            )
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .messageWidth(context.messageMaxWidth(geometry))
                .messageCornerRadius(context.messageCornerRadius)
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
}

private struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(withMessages: [MessagePreview](), withInputBar: {
            BasicInputBarView(message: .constant("Hi"), onSend: {})
        })
    }
}
