//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import Foundation
import SwiftUI

extension MessagesView {
    enum MessageGroupingOption {
        /// Hides profile picture for all but last message in chain from single sender
        case collapseProfilePicture
        
        /// Collapses message header and footer to use first header and last footer for message chain
        case collapseEnclosingViews
    }
    
    internal class MessagesViewContext: ObservableObject {
        internal init() {
            
        }
        
        internal struct CustomRendererConfiguration: Identifiable {
            let id: String
            
            let renderer: (Message) -> AnyView
        }
        
        /// Custom renderers added to handle custom message types
        @Published var customRenderers: [CustomRendererConfiguration] = []
        
        /// Configured grouping options
        @Published var groupingOptions: [MessageGroupingOption] = []
        
        /// Action to perform when chat is refreshed
        @Published var refreshAction: (@Sendable () async -> Void)? = nil
        
        /// `DateFormatter` to use for messages
        @Published var defaultDateFormatter: DateFormatter = DateFormatter()
        
        /// Whether or not to show message timestamps on a lswipe
        @Published var showTimestampOnSwipe: Bool = false
    }
    
    /// Adds a custom renderer to use with a certain kind of custom message
    public func customRenderer<CustomView: View>(forTypeWithID typeID: String, @ViewBuilder _ renderer: @escaping (Message) -> CustomView) -> MessagesView {
        self.context.customRenderers.append(.init(id: typeID, renderer: { (message) in
            return AnyView(renderer(message))
        }))
        
        return self
    }
    
    /// Sets custom grouping options
    public func groupingOptions(_ options: [MessageGroupingOption]) -> MessagesView {
        self.context.groupingOptions = options
        
        return self
    }
    
    /// Sets the `DateFormatter` to use for messages
    public func messageDateFormatter(_ formatter: DateFormatter) -> MessagesView {
        self.context.defaultDateFormatter = formatter
        
        return self
    }
    
    /// Sets whether or not to show message timestamp on swipe
    public func showTimestampOnSwipe(_ showTimestamp: Bool) -> MessagesView {
        self.context.showTimestampOnSwipe = showTimestamp
        
        return self
    }
}
