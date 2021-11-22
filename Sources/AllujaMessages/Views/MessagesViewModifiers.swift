//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import Foundation
import SwiftUI

extension MessagesView {
    public enum MessageGroupingOption {
        /// Hides profile picture for all but last message in chain from single sender
        case collapseProfilePicture

        /// Collapses message header and footer to use first header and last footer for message chain
        case collapseEnclosingViews
    }

    internal class MessagesViewContext: ObservableObject {
        init() {}

        struct CustomRendererConfiguration: Identifiable {
            let id: String

            let renderer: (Message) -> AnyView
        }

        /// Custom renderers added to handle custom message types
        @Published var customRenderers: [CustomRendererConfiguration] = []

        func customRenderer(forID id: String) -> ((Message) -> AnyView)? {
            if let renderer = customRenderers.first(where: { $0.id == id }) {
                return renderer.renderer
            }

            return nil
        }

        /// Configured grouping options
        @Published var groupingOptions: [MessageGroupingOption] = []

        /// Action to perform when chat is refreshed
        @Published var refreshAction: (@Sendable () async -> Void)?

        /// `DateFormatter` to use for messages
        @Published var defaultDateFormatter: DateFormatter = DateFormatter()

        /// Whether or not to show message timestamps on a lswipe
        @Published var showTimestampOnSwipe: Bool = false

        /// Determines whether or not the current message is the last one in a group, defined in `MessagesView.swift` to allow for access to `messages` array
        @Published var messageEndsGroup: (Message) -> Bool = { _ in
            return true
        }

        /// Determines the scale to use for the `ImageView`
        @Published var imageViewScale: CGFloat = 1.0
    }

    /// Adds a custom renderer to use with a certain kind of custom message
    public func customRenderer<CustomView: View>(forTypeWithID typeID: String, @ViewBuilder renderer: @escaping (Message) -> CustomView) -> MessagesView {
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

    /// Sets the rule for whether or not a message ends a group
    public func configureMessageEndsGroup(rule: @escaping (Message) -> Bool) -> MessagesView {
        self.context.messageEndsGroup = rule

        return self
    }

    /// Sets the scale for an `ImageView`
    public func imageViewScale(_ scale: CGFloat) -> MessagesView {
        self.context.imageViewScale = scale

        return self
    }
}
