//
//  MessageGenerator.swift
//  AllujaMessagesExample
//
//  Created by Jack Hogan on 11/23/21.
//

import Foundation
import SwiftUI
import AllujaMessages

private let loremIpsum = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris a tincidunt erat. Nulla id leo id ex efficitur faucibus sit amet ac purus. Nulla elit sem, fringilla consequat tincidunt a, tempor a nulla. Suspendisse potenti. Ut dictum lectus a finibus laoreet. Quisque erat velit, dapibus et leo a, porta sollicitudin urna. Duis porttitor massa in ex vestibulum, ac tempor sapien dignissim. Pellentesque viverra massa semper massa lacinia, faucibus pulvinar purus mollis. Fusce placerat hendrerit fringilla. Vivamus eget pellentesque orci. Duis tempor vitae turpis a lacinia. Integer gravida tempor iaculis. Sed eu lacinia massa. Nam efficitur lacus erat. Integer tincidunt porttitor tellus, nec scelerisque turpis tempus vitae. Duis molestie dui nisi, vel placerat nisi mattis vitae. Aenean nibh nunc, cursus eleifend aliquam a, luctus eu nunc. Nunc pharetra feugiat aliquam. Vivamus vitae dictum elit. Cras eleifend lorem sit amet massa hendrerit, id maximus diam eleifend. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec eget urna nulla. Donec quis viverra ante, sed lobortis diam. Integer bibendum feugiat tortor non eleifend. Ut at posuere augue, ut luctus nisl. Duis ullamcorper turpis faucibus turpis iaculis gravida. Sed quis volutpat ex. Sed finibus lectus vitae lorem molestie, ac ornare libero tincidunt. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam a dignissim tellus, ut dictum lorem. Aenean efficitur non metus vitae rhoncus. Suspendisse scelerisque turpis risus, nec bibendum odio pharetra ultricies. Aenean quis purus id purus ultricies sagittis vitae sit amet arcu. Integer ut magna in velit iaculis vehicula. Mauris at efficitur lectus. Cras finibus, lorem a dapibus cursus, est lacus consectetur erat, at commodo sem lorem nec metus. Aliquam bibendum at libero ut rutrum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Mauris ex nunc, dapibus ut enim et, faucibus faucibus diam. Maecenas odio enim, sollicitudin tincidunt diam id, blandit gravida lorem. Aliquam sodales ante mi, nec pretium sem convallis id. Aenean lobortis lectus a interdum facilisis. Donec ut nunc mauris. Vivamus nec augue scelerisque, blandit urna varius, venenatis velit. Ut sed odio ac diam sodales tristique ut a nibh. Nam sed justo viverra libero elementum vestibulum. Aenean aliquet nisl iaculis ipsum accumsan, ut tincidunt nunc sollicitudin. Praesent mattis tellus id dictum ornare. Maecenas tincidunt id magna ut eleifend. Nulla blandit lectus vel tortor viverra pellentesque. Cras pretium metus orci, vitae bibendum leo commodo vel. Etiam ac elementum orci, eu scelerisque arcu. Etiam eget nisi dolor. Fusce tincidunt bibendum mi, id semper nulla auctor sit amet. Nunc tellus magna, tempor id iaculis porta, tincidunt vel justo. Mauris tempus est eget bibendum suscipit. Nam quis dui sit amet arcu euismod volutpat eu ac ligula. Proin sed placerat dui. Vivamus arcu risus, sodales eget pharetra et, maximus eget purus. Fusce nulla arcu, gravida varius turpis et, tristique fermentum elit. Ut quis laoreet ipsum. Ut commodo pharetra nunc non fringilla. Proin ac arcu vel urna vulputate vulputate sed interdum quam. Nulla sollicitudin, dui sed sollicitudin aliquam, nunc leo mollis nulla, ut ornare diam nulla quis nibh.
"""

private let splitLorem = loremIpsum.split(separator: " ")

private func randomLoremChunk(ofSize size: Int) -> String {
    let boundedSize = min(size, splitLorem.count - 1)

    // Find the max index to use without violating the size
    let maxIndex = splitLorem.count - boundedSize
    let startIndex = Int.random(in: 0...maxIndex)
    return splitLorem[startIndex..<startIndex + size].joined(separator: " ")
}

struct MessageGenerator {

    static func generateMessages(fromAuthors authors: [MessageAlignment], clumpRange: ClosedRange<Int>, clumpQuantity: Int) -> [Message] {
        var senders: [MessageAlignment] = []
        for _ in 0..<clumpQuantity {
            senders.append(authors.randomElement()!)
        }

        var messages: [Message] = []
        for sender in senders {
            messages.append(contentsOf: generateMessages(fromAuthor: sender, quantity: Int.random(in: clumpRange)))
        }
        return messages
    }

    static func generateMessages(fromAuthor author: MessageAlignment, quantity: Int) -> [Message] {
        var messages: [Message] = []
        for _ in 0..<quantity {
            switch Int.random(in: 0...12) {
            case 0..<2:
                messages.append(.init(kind: .system(AttributedString("System Message")), alignment: author))
            case 2..<4:
                messages.append(.init(kind: .image(ImageMessage(imageData: UIImage(named: "Sample1")!.pngData()!, imageURL: nil)), alignment: author))
            case 4..<6:
                messages.append(.init(kind: .image(ImageMessage(imageData: UIImage(named: "Sample2")!.pngData()!, imageURL: nil)), alignment: author))
            case 6..<8:
                messages.append(.init(kind: .custom(CustomMessage(id: "custom1", data: randomLoremChunk(ofSize: 1))), alignment: author))
            case 8..<10:
                messages.append(.init(kind: .custom(CustomMessage(id: "custom2", data: randomLoremChunk(ofSize: 2))), alignment: author))
            default:
                let chunk = randomLoremChunk(ofSize: Int.random(in: 5...15))
                messages.append(.init(kind: .text(TextMessage(text: AttributedString(chunk, attributes: AttributeContainer([.foregroundColor: author == .left ? UIColor.label : UIColor.white])), isClient: author == .right)), alignment: author))
            }
        }
        return messages
    }
}
