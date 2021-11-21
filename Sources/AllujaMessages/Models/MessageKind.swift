//
//  MessageKind.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import Foundation
import SwiftUI

public enum MessageKind {
    case text(AttributedString)
    
    case system([AttributedString])
    
    case media(MediaItem)
    
    case custom(CustomItem)
}

public protocol ViewableMessage {
    associatedtype Message: MessageType
    associatedtype Sender: SenderType
    init(forMessage message: Message, withSender sender: Sender?)
}
