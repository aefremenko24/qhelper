//
//  DropView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

struct DropView: View {
    var body: some View {
        @State var dropping: Bool = false
        
        VStack(spacing: 10) {
            Image(systemName: "lightbulb")
                .font(.system(size: 20))
                .foregroundStyle(.tint)
            Text("Drag and drop your first cue sheet here!")
                .font(.system(size: 16, weight: .bold))
        }
        .padding()
    }
}

#Preview {
    DropView()
}
