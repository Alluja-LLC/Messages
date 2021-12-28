//
//  Previews.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import Foundation
import SwiftUI

internal struct MessageGroup<MessageT: MessageType>: Identifiable {
    let messages: [MessageT]

    let id = UUID()
}

internal struct TextPreview: TextItem {
    let background: Color
    init(isClient: Bool) {
        background = isClient ? .blue : .gray
    }

    var text: AttributedString {
        "Hi"
    }

    var backgroundColor: Color {
        background
    }
}

internal struct ImagePreview: ImageItem {
    let imageData: Data? = nil

    var imageURL: URL?

    func placeholder(forPhase phase: AsyncImagePhase) -> AnyView? {
        AnyView(ProgressView())
    }
}

internal struct MessagePreview: MessageType {
    var alignment: MessageAlignment {
        .left
    }

    var messageID: String {
        "Hi"
    }

    var timestamp: Date {
        Date()
    }

    var kind: MessageKind {
        .text(TextPreview(isClient: alignment == .right))
    }

    var customHeader: AnyView? {
        nil
    }

    var customFooter: AnyView? {
        nil
    }
}
