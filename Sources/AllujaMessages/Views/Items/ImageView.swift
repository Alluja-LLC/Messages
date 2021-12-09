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
    let item: ImageItem
    @State private var image: UIImage?

    init(forItem item: ImageItem, withContext context: MessagesViewContext<MessageT>) {
        self.item = item
        self.context = context
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
            } else if let placeholder = context.imagePlaceholder?(item) {
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
        ImageView(forItem: ImagePreview(), withContext: MessagesViewContext<MessagePreview>(messages: []))
    }
}
