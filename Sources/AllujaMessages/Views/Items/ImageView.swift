//
//  ImageView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

struct ImageView: View {
    @Environment(\.messageCornerRadius) var cornerRadius
    let item: ImageItem

    init(forItem item: ImageItem) {
        self.item = item
    }

    var body: some View {
        Group {
            if let imageData = item.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
            } else if let url = item.imageURL {
                AsyncImage(url: url, scale: 1.0, content: { phase in
                    if case .success(let image) = phase {
                        image
                    } else if let placeholder = item.placeholder(forPhase: phase) {
                        placeholder
                    } else {
                        ProgressView()
                    }
                })
            } else {
                ProgressView()
            }
        }
        .cornerRadius(cornerRadius)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(forItem: ImagePreview())
    }
}
