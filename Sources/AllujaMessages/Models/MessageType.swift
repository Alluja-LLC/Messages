//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import Foundation
import SwiftUI

public enum MessageAlignment {
    case left, right
}

public protocol MessageType: Equatable {
    /// Unique ID that identifies this message
    var messageID: String { get }

    /// When the message was sent
    var timestamp: Date { get }

    /// The kind of message
    var kind: MessageKind { get }
    
    /// Determines which side the message is placed on
    /// This is ignored for messages with a `.system` kind and all custom messages
    var alignment: MessageAlignment { get }
}
