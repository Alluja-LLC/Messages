//
//  File.swift
//  
//
//  Created by Jack Hogan on 12/2/21.
//

import Foundation
import SwiftUI

internal struct MessageContainer<MessageT: MessageType> {
    let message: MessageT
    var id: String {
        message.id
    }
    var size: CGSize = .zero
}

internal struct MessageGroupContainer<MessageT: MessageType> {
    let messages: [MessageT]

    var id: String {
        messages.first!.id
    }
    
    var size: CGSize = .zero
}
