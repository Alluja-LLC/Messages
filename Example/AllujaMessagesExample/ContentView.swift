//
//  ContentView.swift
//  AllujaMessagesExample
//
//  Created by Jack Hogan on 11/19/21.
//

import SwiftUI
import AllujaMessages

fileprivate let senders: [Sender] = [
    Sender(id: "SELF", position: .right),
    Sender(id: "OTHER1", position: .left),
    Sender(id: "OTHER2", position: .left),
    Sender(id: "OTHER3", position: .left)
]

struct ContentView: View {
    @State private var messages: [Message]
    @State private var messageBar: String = ""
    let messageFormatter: DateFormatter
    
    init() {
        _messages = State(initialValue: MessageGenerator.generateMessages(fromAuthors: senders, clumpRange: 1...3, clumpQuantity: 5))
        messageFormatter = DateFormatter()
        messageFormatter.dateFormat = "MMM d, h:mm a"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Loaded \(messages.count) messages")
                    .foregroundColor(.green)
                MessagesView(withMessages: messages, withInputBar: {
                    HStack {
                        // Hack to get TextEditor to have resizeable height
                        Text(messageBar)
                            .foregroundColor(.clear)
                            .padding(8)
                            .lineLimit(4)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                TextEditor(text: $messageBar)
                                    .cornerRadius(4)
                            )
                        
                        Button("Send") {
                            messages.append(.init(kind: .text(TextMessage(text: AttributedString(messageBar, attributes: AttributeContainer([.foregroundColor: UIColor.white])), isClient: true)), sender: senders[0]))
                            messageBar = ""
                            // UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(messageBar.isEmpty)
                        .animation(.easeInOut(duration: 0.2), value: messageBar.isEmpty)
                    }
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing])
                    .background(Color(uiColor: .systemGray6).edgesIgnoringSafeArea([.leading, .trailing, .bottom]))
                })
                .messageDateFormatter(messageFormatter)
                .refreshable {
                    print("REF")
                }
                .navigationTitle("Messages Test")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
