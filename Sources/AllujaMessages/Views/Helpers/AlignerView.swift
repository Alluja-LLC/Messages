//
//  SwiftUIView.swift
//  
//
//  Created by Jack Hogan on 11/22/21.
//

import SwiftUI

struct AlignerView<WrappedT: View>: View {
    let alignment: SenderAlignment
    let view: () -> WrappedT

    var body: some View {
        GeometryReader { geometry in
            switch alignment {
            case .left:
                HStack {
                    view().frame(width: geometry.size.width * 3 / 4)
                    Spacer()
                }
            case .center:
                view()
            case .right:
                HStack {
                    Spacer()
                    view().frame(width: geometry.size.width * 3 / 4)
                }
            }
        }
    }
}

struct Aligneriew_Previews: PreviewProvider {
    static var previews: some View {
        AlignerView(alignment: .center) {
            Text("Hi")
        }
    }
}
