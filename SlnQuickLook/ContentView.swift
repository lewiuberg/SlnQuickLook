//
//  ContentView.swift
//  SlnQuickLook
//
//  Created by Lewi Uberg on 18/03/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text("SlnQuickLook")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Quick Look preview extension for .sln and .slnx files")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Select a .sln or .slnx file in Finder and press Space to preview")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(40)
        .frame(maxWidth: 400)
    }
}

#Preview {
    ContentView()
}
