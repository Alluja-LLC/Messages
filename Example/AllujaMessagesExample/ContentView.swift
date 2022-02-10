//
//  ContentView.swift
//  AllujaMessagesExample
//
//  Created by Jack Hogan on 11/19/21.
//

import SwiftUI
import AllujaMessages

private let senders: [MessageAlignment] = [
    .right, .left, .left, .left
]

struct ContentView: View {
    @State private var messages: [Message]
    @State private var messageBar: String = ""
    
    @State private var showTimestamps: Bool = true
    @State private var footerContentChange: Bool = false
    @State private var groupMessages: Bool = false
    @State private var groupTimestamps: Bool = false
    
    let messageFormatter: DateFormatter

    init() {
        _messages = State(initialValue: MessageGenerator.generateMessages(fromAuthors: senders, clumpRange: 1...3, clumpQuantity: 5))
        messageFormatter = DateFormatter()
        messageFormatter.dateFormat = "MMM d, h:mm a"
    }

    private var groupingOptions: [MessageGroupingOption] {
        var opts: [MessageGroupingOption] = []
        if groupMessages {
            opts.append(.collapseEnclosingViews)
        }
        if groupTimestamps {
            opts.append(.collapseTimestamps(.top))
        }
        return opts
    }

    var body: some View {
        NavigationView {
            MessagesView(withMessages: messages, withInputBar: {
                BasicInputBarView(message: $messageBar) {
                    messages.append(.init(kind: .text(TextMessage(text: AttributedString(messageBar, attributes: AttributeContainer([.foregroundColor: UIColor.white])), isClient: true)), alignment: senders[0]))
                    messageBar = ""
                }
            })
            .groupingOptions(groupingOptions)
            .messageTimestampFormatter(messageFormatter)
            .messageContextMenu { message in
                Text("\(message.messageID)")
                Text("Menu")
            }
            .messageHeader { message in
                Text(message.messageID)
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.gray)
            }
            .messageFooter { _ in
                if footerContentChange {
                    EmptyView()
                } else {
                    Text("FOOTER")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                }
            }
            .messageAvatar { message in
                if case .custom(_) = message.kind {
                    EmptyView()
                } else {
                    LinearGradient(colors: [.purple, .red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
            }
            .proxyOnAppear { value in
                withAnimation {
                    value.scrollTo(messages.last?.messageID)
                }
            }
            .proxyOnMessagesChange { value, msgs in
                withAnimation {
                    value.scrollTo(msgs.last?.messageID)
                }
            }
            .customRenderer(forTypeWithID: "custom1") { message, _ in
                if case .custom(let item) = message.kind {
                    Text("Custom 1: Hi, \(item.data as? String ?? "unknown")")
                        .foregroundColor(.accentColor)
                } else {
                    Text("Error!")
                }
            }
            .customRenderer(forTypeWithID: "custom2") { message, info in
                HStack {
                    if message.alignment == .right {
                        Spacer()
                    }
                    
                    if case .custom(let item) = message.kind {
                        Text("Custom 2: Bye, \(item.data as? String ?? "unknown")")
                            .frame(width: info.suggestedWidth, alignment: message.alignment == .right ? .trailing : .leading)
                    } else {
                        Text("Error!")
                    }
                    
                    if message.alignment == .left {
                        Spacer()
                    }
                }
            }
            .showTimestampsOnSwipe(showTimestamps)
            .refreshable {
                print("REF")
            }
            .navigationTitle("Messages Test")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Menu(content: {
                        Text("Loaded \(messages.count) messages")
                        Button("Randomize Messages") {
                            messages = MessageGenerator.generateMessages(fromAuthors: senders, clumpRange: 1...3, clumpQuantity: 5)
                        }
                    }, label: {
                        Text("\(messages.count)")
                            .foregroundColor(.green)
                    })
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Toggle("Show Timestamps", isOn: $showTimestamps)
                        Toggle("Change Footer", isOn: $footerContentChange)
                        Toggle("Group Messages", isOn: $groupMessages)
                        Toggle("Group Timestamps", isOn: $groupTimestamps)
                    }, label: {
                        Image(systemName: "slider.horizontal.3")
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
