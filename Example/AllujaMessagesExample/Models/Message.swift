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

struct ImageMessage: ImageItem {
    var imageData: Data?

    var imageURL: URL?
}

struct CustomMessage: CustomItem {
    var id: String

    var data: Any?
}

struct Message: MessageType {
    init(kind: MessageKind, alignment: MessageAlignment) {
        self.alignment = alignment
        self.messageID = UUID().uuidString
        self.kind = kind
    }

    let timestamp: Date = Date()

    let kind: MessageKind

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.messageID == rhs.messageID
    }

    let messageID: String
    
    let alignment: MessageAlignment
}
