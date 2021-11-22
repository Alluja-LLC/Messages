//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import Foundation
import SwiftUI

public protocol MessageType: Identifiable, Equatable {
    /// Optional to allow for special messages without a sender
    associatedtype Sender: SenderType
    var sender: Sender? { get }
    
    /// Unique ID that identifies this message
    var id: String { get }
    
    /// When the message was sent
    var timestamp: Date { get }
    
    /// The type of message
    var kind: MessageKind { get }
    
    /// Custom header for the message
    var customHeader: AnyView? { get }
    
    /// Custom footer for the message
    var customFooter: AnyView? { get }
}

public protocol SenderType: Identifiable {
    /// Unique ID for each sender
    var id: String { get }
    
    /// Display name for each sender
    var displayName: String { get }
    
    /// Profile image data for each sender, takes priority over URL
    var profileImageData: Data? { get }
    
    /// Profile image URL for each sender
    var profileImageURL: URL? { get }
    
    /// Determines which side the message is placed on
    var isClient: Bool { get }
}
