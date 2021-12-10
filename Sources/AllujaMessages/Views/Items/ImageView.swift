//
//  ImageView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

internal struct ImageView<MessageT: MessageType>: View {
    @Environment(\.messageWidth) private var width
    @Environment(\.messageCornerRadius) private var cornerRadius
    @ObservedObject private var context: MessagesViewContext<MessageT>
    let message: MessageT
    let item: ImageItem
    @State private var image: UIImage?

    init(forMessage message: MessageT, withContext context: MessagesViewContext<MessageT>) {
        self.message = message
        self.context = context
        
        guard case .image(let item) = message.kind else { fatalError("This shouldn't be possible to execute") }
        
        self.item = item
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
            } else if let placeholder = context.imagePlaceholder?(message) {
                placeholder
            } else {
                ProgressView()
            }
        }
        .cornerRadius(cornerRadius)
        .onAppear {
            if let data = item.imageData, image == nil {
                processImageData(data)
            }
        }
        .task {
            guard let url = item.imageURL, image == nil else { return }

            guard let (data, _) = try? await URLSession.shared.data(from: url, delegate: nil) else { return }

            processImageData(data)
        }
    }

    private func processImageData(_ data: Data) {
        if let tempImage = UIImage(data: data, scale: 1.0) {
            var image = tempImage
            if tempImage.size.width > width {
                image = UIImage(data: data, scale: image.size.width / width)!
            }
            self.image = image
        }
    }
}

private struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(forMessage: MessagePreview(), withContext: MessagesViewContext<MessagePreview>(messages: []))
    }
}
