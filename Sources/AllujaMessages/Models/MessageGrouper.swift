//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/21/21.
//

import Foundation

public protocol MessageGrouper {
    associatedtype Message: MessageType
    func isLastOfGroup(_ message: Message, fromMessages: [Message]) -> Bool
}


