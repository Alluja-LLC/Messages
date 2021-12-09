//
//  BasicInputBarView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

public struct BasicInputBarView: View {
    @Binding private var message: String
    private let onSend: () -> Void

    public init(message: Binding<String>, onSend: @escaping () -> Void) {
        self._message = message
        self.onSend = onSend
    }

    public var body: some View {
        HStack {
            // Hack to get TextEditor to have resizeable height
            Text(message)
                .foregroundColor(.clear)
                .padding(8)
                .lineLimit(4)
                .frame(maxWidth: .infinity)
                .overlay(
                    TextEditor(text: $message)
                        .cornerRadius(4)
                )

            Button("Send") {
                onSend()
            }
            .buttonStyle(.borderedProminent)
            .disabled(message.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: message.isEmpty)
        }
        .padding([.top, .bottom], 8)
        .padding([.leading, .trailing])
        .background(Color(uiColor: .systemGray6).edgesIgnoringSafeArea([.leading, .trailing, .bottom]))
    }
}

private struct BasicInputBarView_Previews: PreviewProvider {
    static var previews: some View {
        BasicInputBarView(message: .constant("Test"), onSend: {})
    }
}
