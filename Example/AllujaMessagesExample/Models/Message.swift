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
    let timestamp: Date = Date()
    
    let kind: MessageKind
    
    let customHeader: AnyView? = nil
    
    var customFooter: AnyView? {
        AnyView(Text(sender.displayName))
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    let sender: Sender
    
    var id: String {
        UUID().uuidString
    }
}

struct Sender: SenderType {
    let id: String
    
    let displayName: String = "Some Sender"
    
    let profileImageData: Data? = nil
    
    let profileImageURL: URL? = nil
    
    func placeholder(forPhase phase: AsyncImagePhase) -> AnyView? {
        nil
    }
    
    var position: SenderAlignment
    
    
}
