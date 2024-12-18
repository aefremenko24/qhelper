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
            Image(systemName: "document.viewfinder")
                .font(.system(size: 30))
                .foregroundStyle(.tint)
            Text("Drop a lighting cues sheet here to begin")
                .font(.system(size: 16, weight: .bold))
        }
        .padding()
    }
}

#Preview {
    DropView()
}
