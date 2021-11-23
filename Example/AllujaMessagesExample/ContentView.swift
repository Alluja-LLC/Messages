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
    
    init() {
        _messages = State(initialValue: MessageGenerator.generateMessages(fromAuthors: senders, clumpRange: 1...3, clumpQuantity: 5))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Loaded \(messages.count) messages")
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
                            )
                        
                        Button("Send") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing])
                    .background(Color(uiColor: .systemGray6).edgesIgnoringSafeArea(.bottom))
                })
                .refreshAction {
                    print("REFRESH")
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
