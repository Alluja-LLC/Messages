//
//  ProfilePictureView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

internal struct ProfilePictureView<Sender: SenderType>: View {
    let sender: Sender

    init(forSender sender: Sender) {
        self.sender = sender
    }

    var body: some View {
        Group {
            if let data = sender.profileImageData, let image = UIImage(data: data) {
                Image(uiImage: image)
            } else if let url = sender.profileImageURL {
                AsyncImage(url: url, scale: 1.0, content: { phase in
                    if case .success(let image) = phase {
                        image
                    } else if let placeholder = sender.placeholder(forPhase: phase) {
                        placeholder
                    } else {
                        ProgressView()
                    }
                })
            } else {
                ProgressView()
            }
        }
        .clipShape(Circle())
    }
}

private struct ProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureView(forSender: SenderPreview())
    }
}
