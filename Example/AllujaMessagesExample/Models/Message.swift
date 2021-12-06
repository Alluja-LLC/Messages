//
//  Message.swift
//  AllujaMessagesExample
//
//  Created by Jack Hogan on 11/23/21.
//

import Foundation
import AllujaMessages
import SwiftUI

struct TextMessage: TextItem {
    init(text: AttributedString, isClient: Bool) {
        self.text = text
        self.backgroundColor = isClient ? Color(uiColor: .systemBlue) : Color(uiColor: .systemGray5)
    }
    
    var text: AttributedString
    
    var backgroundColor: Color
}

struct Message: MessageType {
    init(kind: MessageKind, sender: Sender) {
        self.sender = sender
        self.id = UUID().uuidString
        self.kind = kind
    }
    
    let timestamp: Date = Date()
    
    let kind: MessageKind
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    let sender: Sender
    
    let id: String
}

struct Sender: SenderType {
    let id: String
    
    let displayName: String = "Some Sender"
    
    var position: SenderAlignment
    
    
}
