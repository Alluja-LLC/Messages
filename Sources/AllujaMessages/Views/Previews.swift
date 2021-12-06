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
    var sender: SenderPreview {
        SenderPreview()
    }

    var id: String {
        "Hi"
    }

    var timestamp: Date {
        Date()
    }

    var kind: MessageKind {
        .text(TextPreview(isClient: sender.position == .right))
    }

    var customHeader: AnyView? {
        nil
    }

    var customFooter: AnyView? {
        nil
    }
}

internal struct SenderPreview: SenderType {
    func placeholder(forPhase phase: AsyncImagePhase) -> AnyView? {
        nil
    }

    var displayName: String {
        "Test Name"
    }

    var id: String {
        "Test"
    }

    var position: SenderAlignment {
        .left
    }
}
