//
//  Environment.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import Foundation
import SwiftUI

private struct MessageCornerRadius: EnvironmentKey {
    static let defaultValue: CGFloat = 8.0
}

private struct MessageWidth: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

internal extension EnvironmentValues {
    var messageCornerRadius: CGFloat {
        get { self[MessageCornerRadius.self] }
        set { self[MessageCornerRadius.self] = newValue }
    }
}

/// Allows custom messages to conform to `messageWidth` without having access to setters
public extension EnvironmentValues {
    var messageWidth: CGFloat {
        get { self[MessageWidth.self] }
        set { self[MessageWidth.self] = newValue }
    }
}

internal extension View {
    func messageCornerRadius(_ cornerRadius: CGFloat) -> some View {
        environment(\.messageCornerRadius, cornerRadius)
    }
    
    func messageWidth(_ width: CGFloat) -> some View {
        environment(\.messageWidth, width)
    }
}
