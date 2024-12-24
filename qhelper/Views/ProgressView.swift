//
//  ProgressView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 12/24/24.
//

import SwiftUI

struct ProgressView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.5))
            Text("Loading...")
                .font(.largeTitle)
        }
    }
}

#Preview {
    ProgressView()
}
