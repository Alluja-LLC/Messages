//
//  File.swift
//  
//
//  Created by Jack Hogan on 12/2/21.
//

import Foundation
import SwiftUI

internal enum MessageGroupFlag {
    /// Instructs view to render header
    case renderHeader

    /// Instructs view to render footer
    case renderFooter

    /// Renders the profile view
    case renderProfile

    /// Renders a space for the profile view without the view itself, dependent on size of other profile views
    case renderClearProfile

    /// Adds pre-group padding
    case startGroup

    /// Adds post-group padding
    case endGroup
}

internal enum MessageGroupTimestampFlag {
    case normal
    case top
    case bottom
    case hidden
}

internal struct MessageContainer<MessageT: MessageType>: Identifiable, Equatable {
    let message: MessageT
    var groupFlags: Set<MessageGroupFlag> = []
    var timestampFlag: MessageGroupTimestampFlag = .normal

    var id: String {
        message.messageID
    }

    func groupFlagsEmptyOrContains(_ flag: MessageGroupFlag) -> Bool {
        groupFlags.isEmpty || groupFlags.contains(flag)
    }
}
