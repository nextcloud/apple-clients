//
//  WebLoadingView.swift
//  NextSync
//
//  Created by Claudio Cambra on 21/4/24.
//

import Foundation
import SwiftUI

struct WebLoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    @Binding var progress: Double
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(isShowing)
                    .blur(radius: isShowing ? 3 : 0)

                VStack {
                    Text("Loading...")
                        .bold()
                    ProgressView()
                        .progressViewStyle(.circular)
                    ProgressView(value: progress, total: 1.0)
                        .padding()
                }
                .frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .cornerRadius(20)
                .opacity(isShowing ? 1 : 0)
            }
        }
    }
}
