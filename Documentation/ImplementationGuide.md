#  Implementation Guide

## Basic Concepts and Protocols

Many of the concepts here are similar to [MessageKit](https://github.com/MessageKit/MessageKit), so if you are familiar with that library you will be able to get going very quickly.

### [`MessageType`](../Sources/AllujaMessages/Models/MessageType.swift)
`MessageType` is the basic protocol used to represent messages and contains all necessary information to do so.

```swift
public enum MessageAlignment {
    case left, right
}

public protocol MessageType: Identifiable, Equatable {
    /// Unique ID that identifies this message
    var id: String { get }

    /// When the message was sent
    var timestamp: Date { get }

    /// The kind of message
    var kind: MessageKind { get }
    
    /// Determines which side the message is placed on
    /// This is ignored for messages with a `.system` kind and all custom messages
    var alignment: MessageAlignment { get }
}
```

[`MessageKind`](../Sources/AllujaMessages/Models/MessageKind.swift) determines the type of message and how it is displayed. There are a few kinds built in by default with an option for custom messages:

```swift
public enum MessageKind {
    case text(TextItem)

    case system(AttributedString)

    case image(ImageItem)

    case custom(CustomItem)
}
```

All of these have protocols or types that define a message's information, the files for which are [here](../Sources/AllujaMessages/Models/Items).

## [`MessagesView`](../Sources/AllujaMessages/Views/MessagesView.swift)
This is the main view of the library, taking the messages to be shown and an input bar view. [`BasicInputBarView`](../Sources/AllujaMessages/Views/BasicInputBarView.swift) is provided if you don't want to make your own. Many different options can be chained onto this view to modify it, all of which are explained below.

# `MessagesView` Modifiers

All of the modifiers are defined in [`MessagesViewModifiers.swift`](../Sources/AllujaMessages/Views/MessagesViewModifiers.swift).

## Grouping
AllujaMessages has built-in support for message grouping along with multiple ways to customize it. This puts messages together if they fall under a certain rule (changeable by the `configureMessageEndsGroup()` modifier).

To enable grouping, chain the `.groupingOptions()` to your `MessagesView`.

The options for grouping are as follows:
```swift
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
```

## Headers, Footers, and Avatars

## Context Menus

## ScrollViewReader Control

## Custom Messages

## Miscellaneous Modifiers