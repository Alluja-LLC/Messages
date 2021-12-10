//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/19/21.
//

import Foundation
import SwiftUI

internal extension View {
    @ViewBuilder func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}
