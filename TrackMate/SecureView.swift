//
//  SecureView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import LocalAuthentication

struct SecureView<Content: View>: View {
    let content: Content
    @AppStorage("requirePinFallback") private var requirePinFallback: Bool = false
    @AppStorage("pinCode") private var pinCode: String = ""
    @AppStorage("biometricUnlocked") private var isUnlocked: Bool = false
    @AppStorage("lastAuthDate") private var lastAuthDate: Date?
    private let timeoutInterval: TimeInterval = 5 * 60
    
    @State private var showingPinPrompt = false
    @State private var enteredPin = ""
    @State private var pinError: String?
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private var shouldshowContent: Bool {
        guard isUnlocked, let last = lastAuthDate else { return false }
        return Date().timeIntervalSince(last) < timeoutInterval
    }
    
    var body: some View {
        Group {
            if shouldshowContent {
                content
            } else {
                lockedView
            }
        }
        .onAppear(perform: checkTimeout)
    }
    
    private var lockedView: some View {
        VStack(spacing: 20) {
            Text("Locked")
                .font(.title)
            Button("Unlock") {
                authenticate()
            }
        }
        .padding()
        .onAppear(perform: authenticate)
    }
    
    private func checkTimeout() {
        if let last = lastAuthDate,
           Date().timeIntervalSince(last) > timeoutInterval {
            isUnlocked = false
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to view sensitive data"
            ) { success, error in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        lastAuthDate = Date()
                    } else {
                        fallbackToPasscode(context: context)
                    }
                }
            }
        } else {
            fallbackToPasscode(context: context)
        }
    }
    
    
    private func fallbackToPasscode(context: LAContext) {
        if requirePinFallback {
            DispatchQueue.main.async { showingPinPrompt = true }
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "Authenticate with device passcode") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        lastAuthDate = Date()
                    }
                }
            }
        }
    }
}

