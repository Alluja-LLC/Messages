//
//  MessageTimestampView.swift
//  
//
//  Created by Jack Hogan on 12/1/21.
//

import SwiftUI

struct MessageTimestampView: View {
    let timestamp: Date
    let formatter: DateFormatter

    var body: some View {
        VStack(alignment: .center) {
            Text(formatter.string(from: timestamp))
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}

private struct MessageTimestampView_Previews: PreviewProvider {
    static var formatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, h:mm a"
        return fmt
    }

    static var previews: some View {
        MessageTimestampView(timestamp: Date(), formatter: formatter)
    }
}
