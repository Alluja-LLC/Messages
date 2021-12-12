//
//  File.swift
//  
//
//  Created by Jack Hogan on 11/20/21.
//

import Foundation
import SwiftUI

public enum TimestampPositionAnchor: Equatable {
    case bottom, top
}

public enum MessageGroupingOption: Equatable {
    /// Hides profile picture for all but last message in group
    case collapseProfilePicture

    /// Collapses message header and footer to use first header and last footer for message chain
    case collapseEnclosingViews

    /// Collapses all timestamps to a single one either at the absolute top or bottom of the group
    case collapseTimestamps(TimestampPositionAnchor)
}

/// Holds information that is useful for custom message renderers
public struct CustomRendererInfo {
    internal init(width: CGFloat, cornerRadius: CGFloat) {
        suggestedWidth = width
        suggestedCornerRadius = cornerRadius
    }
    
    public let suggestedWidth: CGFloat
    public let suggestedCornerRadius: CGFloat
}

internal class MessagesViewContext<MessageT: MessageType>: ObservableObject {
    init(messages: [MessageT]) {
        updateMessages(messages)
    }

    @Published var messages: [MessageContainer<MessageT>] = []

    var maxTimestampViewWidth: CGFloat {
        messages.reduce(CGFloat.zero, { res, message in
            max(res, message.size.width)
        })
    }

    func updateMessages(_ messages: [MessageT]) {
        // Iterate over each message and see if the next one is last
        var completeContainers: [MessageContainer<MessageT>] = []
        // Whether or not to attempt to place a footer on the next iteration
        var footerFallthrough: Bool = false
        for (i, message) in messages.sorted(by: { $0.timestamp < $1.timestamp }).enumerated() {
            // Figure out what options are needed for each message
            var flags: Set<MessageGroupFlag> = []
            var timestampFlag: MessageGroupTimestampFlag = .hidden

            // If this is the first message OR the last message ends the group then add flag
            if completeContainers.isEmpty || completeContainers[completeContainers.index(before: i)].groupFlags.contains(.endGroup) {
                if case .collapseTimestamps(let anchor) = groupingOptions.first(where: { item in
                    if case .collapseTimestamps(_) = item {
                        return true
                    }
                    return false
                }), anchor == .top {
                    timestampFlag = .top
                }

                flags.insert(.startGroup)
            }

            if messageEndsGroup(message) {
                if case .collapseTimestamps(let anchor) = groupingOptions.first(where: { item in
                    if case .collapseTimestamps(_) = item {
                        return true
                    }
                    return false
                }), anchor == .bottom {
                    timestampFlag = .bottom
                }

                flags.insert(.endGroup)
            }

            // If there aren't any timestamp grouping options, then display timestamp normally
            if case .collapseTimestamps(_) = groupingOptions.first(where: { item in
                if case .collapseTimestamps(_) = item {
                    return true
                }
                return false
            }) {

            } else {
                timestampFlag = .normal
            }

            switch message.kind {
            case .system(_):
                if flags.contains(.endGroup) && !flags.contains(.startGroup) && i != messages.startIndex {
                    completeContainers[completeContainers.index(before: completeContainers.endIndex)].groupFlags.insert(.renderFooter)
                } else if flags.contains(.startGroup) && !flags.contains(.endGroup) {
                    footerFallthrough = true
                }
            default:
                if groupingOptions.contains(.collapseEnclosingViews) {
                    if flags.contains(.startGroup) {
                        flags.insert(.renderHeader)
                    }

                    if flags.contains(.endGroup) || footerFallthrough {
                        flags.insert(.renderFooter)
                        footerFallthrough = false
                    }
                } else {
                    flags.insert(.renderHeader)
                    flags.insert(.renderFooter)
                }

                if groupingOptions.contains(.collapseProfilePicture) {
                    if flags.contains(.endGroup) {
                        flags.insert(.renderProfile)
                    } else {
                        flags.insert(.renderClearProfile)
                    }
                } else {
                    flags.insert(.renderProfile)
                }
            }
            completeContainers.append(.init(message: message, groupFlags: flags, timestampFlag: timestampFlag))
        }

        self.messages = completeContainers
    }

    struct CustomRendererConfiguration: Identifiable {
        let id: String

        let renderer: (MessageT, CustomRendererInfo) -> AnyView
    }

    /// Custom renderers added to handle custom message types
    @Published var customRenderers: [CustomRendererConfiguration] = []

    func customRenderer(forID id: String) -> ((MessageT, CustomRendererInfo) -> AnyView)? {
        if let renderer = customRenderers.first(where: { $0.id == id }) {
            return renderer.renderer
        }

        return nil
    }

    /// Custom header and footer options
    @Published var header: ((MessageT) -> AnyView)?
    @Published var footer: ((MessageT) -> AnyView)?

    /// Configured grouping options
    @Published var groupingOptions: [MessageGroupingOption] = [] {
        didSet {
            updateMessages(messages.map { $0.message })
        }
    }

    /// `DateFormatter` to use for messages
    @Published var messageTimestampFormatter: DateFormatter = DateFormatter()

    /// Whether or not to show message timestamps on a lswipe
    @Published var showTimestampsOnSwipe: Bool = false

    /// Determines whether or not the current message is the last one in a group, defined in `MessagesView.swift` to allow for access to `messages` array
    @Published var messageEndsGroup: (MessageT) -> Bool = { _ in
        return true
    } {
        didSet {
            updateMessages(messages.map { $0.message })
        }
    }

    /// Context menu for each message
    @Published var messageContextMenu: ((MessageT) -> AnyView)?

    /// Custom image placeholder
    @Published var messageImagePlaceholder: ((MessageT) -> AnyView)?

    /// Avatar view for message
    @Published var avatar: ((MessageT) -> AnyView)?
    
    /// Called when the messages view appears or messages array changes respectively, allows for control over the ScrollViewReader
    @Published var proxyOnAppear: ((ScrollViewProxy) -> Void)?
    @Published var proxyOnMessagesChange: ((ScrollViewProxy, [MessageT]) -> Void)?
    
    /// Message style changes
    @Published var messageMaxWidth: ((GeometryProxy) -> CGFloat) = { geometry in
        geometry.size.width * 3 / 4
    }
    @Published var messageCornerRadius: CGFloat = 8.0
}

extension MessagesView {
    /// Adds a custom renderer to use with a certain kind of custom message
    public func customRenderer<CustomView: View>(forTypeWithID typeID: String, @ViewBuilder renderer: @escaping (MessageT, CustomRendererInfo) -> CustomView) -> MessagesView {
        context.customRenderers.append(.init(id: typeID, renderer: { (message, suggestedWidth) in
            return AnyView(renderer(message, suggestedWidth))
        }))

        return self
    }

    /// Sets custom grouping options
    public func groupingOptions(_ options: [MessageGroupingOption]) -> MessagesView {
        context.groupingOptions = options

        return self
    }

    /// Sets the `DateFormatter` to use for messages
    public func messageTimestampFormatter(_ formatter: DateFormatter) -> MessagesView {
        context.messageTimestampFormatter = formatter

        return self
    }

    /// Sets whether or not to show message timestamp on swipe
    public func showTimestampsOnSwipe(_ showTimestamps: Bool) -> MessagesView {
        context.showTimestampsOnSwipe = showTimestamps

        return self
    }

    /// Sets the rule for whether or not a message ends a group
    public func configureMessageEndsGroup(rule: @escaping (MessageT) -> Bool) -> MessagesView {
        context.messageEndsGroup = rule

        return self
    }

    /// Adds a view for all message headers customizable to each message
    public func messageHeader<HeaderView: View>(@ViewBuilder builder: @escaping (MessageT) -> HeaderView) -> MessagesView {
        context.header = { message in
            AnyView(builder(message))
        }

        return self
    }

    /// Adds a view for all message footers customizable to each message
    public func messageFooter<FooterView: View>(@ViewBuilder builder: @escaping (MessageT) -> FooterView) -> MessagesView {
        context.footer = { message in
            AnyView(builder(message))
        }

        return self
    }

    /// Adds a context menu for all messages customizable to each message
    public func messageContextMenu<MenuItems: View>(@ViewBuilder builder: @escaping (MessageT) -> MenuItems) -> MessagesView {
        context.messageContextMenu = { message in
            AnyView(builder(message))
        }

        return self
    }

    /// Adds a placeholder view for all image views customizable to each image
    public func messageImagePlaceholder<PlaceholderView: View>(@ViewBuilder builder: @escaping (MessageT) -> PlaceholderView) -> MessagesView {
        self.context.messageImagePlaceholder = { imageItem in
            AnyView(builder(imageItem))
        }

        return self
    }

    public func messageAvatar<AvatarView: View>(@ViewBuilder builder: @escaping (MessageT) -> AvatarView) -> MessagesView {
        context.avatar = { message in
            AnyView(builder(message))
        }

        return self
    }
    
    public func proxyOnAppear(perform action: @escaping (ScrollViewProxy) -> Void) -> MessagesView {
        context.proxyOnAppear = action
        
        return self
    }
    
    public func proxyOnMessagesChange(perform action: @escaping (ScrollViewProxy, [MessageT]) -> Void) -> MessagesView {
        context.proxyOnMessagesChange = action
        
        return self
    }
    
    public func messageMaxWidth(calculator: @escaping (GeometryProxy) -> CGFloat) -> MessagesView {
        context.messageMaxWidth = calculator
        
        return self
    }
    
    public func messageCornerRadius(_ cornerRadius: CGFloat) -> MessagesView {
        context.messageCornerRadius = cornerRadius
        
        return self
    }
}
