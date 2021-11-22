//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/21/21.
//

import Foundation
import SwiftUI

public protocol TextItem {
    /// Text content
    var text: AttributedString { get }

    /// Color of bubble
    var backgroundColor: Color { get }
}
