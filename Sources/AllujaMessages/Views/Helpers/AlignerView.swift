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
        switch alignment {
        case .left:
            HStack {
                view()
                GeometryReader { geometry in
                    Spacer()
                        .frame(width: geometry.size.width / 2)
                }
            }
            .border(.purple, width: 2)
        case .center:
            view()
        case .right:
            GeometryReader { geometry in
                HStack {
                    Spacer()
                        .frame(width: geometry.size.width / 4)
                    view()
                        .frame(maxHeight: .infinity)
                }
                .frame(height: geometry.size.height)
            }
            .frame(maxHeight: .infinity)
            .border(.purple, width: 2)
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
