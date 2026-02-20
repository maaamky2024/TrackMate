//
//  ToastBanner.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/28/25.
//

import SwiftUI

struct ToastBanner: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(radius: 8)
            .padding(.top, 10)
            .padding(.horizontal)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isPresented {
                ToastBanner(text: text)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut) { isPresented = false }
                            onDismiss?()
                        }
                            
                    }
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, text: String, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(ToastModifier(isPresented: isPresented, text: text, onDismiss: onDismiss))
    }
}
