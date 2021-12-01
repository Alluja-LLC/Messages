//
//  MessageKind.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import Foundation

public enum MessageKind {
    case text(TextItem)

    case system(AttributedString)

    case image(ImageItem)

    case custom(CustomItem)
}
