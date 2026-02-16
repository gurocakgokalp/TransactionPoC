//
//  ContentView.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//


import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var currentDetent: PresentationDetent = .fraction(0.1)
    @State private var isHandshakeComplete: Bool = true
    @State private var isEnrolled: Bool = false
    
    @State var password: String = ""
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .center, spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "building.columns")
                            .foregroundStyle(.purple.gradient)
                            .font(.title)
                        Text("Transaction PoC")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Simulate a secure money transfer. Amount is encrypted with CryptoKit, sent to Vapor (backend), and verified.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    HStack {
                        Image(systemName: "turkishlirasign")
                        TextField("Transaction amount", text: $password)
                            .keyboardType(.asciiCapable)
                            .textInputAutocapitalization(.characters)
                            .onChange(of: password) { _ , newValue in
                                let allowed = "0123456789"
                                password = String(
                                    newValue
                                        .uppercased()
                                        .filter { allowed.contains($0) }
                                        .prefix(6)
                                )
                            }
                    }.padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .padding()
                    

                    Button(action: { }) {
                        HStack {
                            Text("Send Transaction")
                                .fontWeight(.bold)
                            Image(systemName: "paperplane.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.purple.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 10, x: 0, y: 5)
                    }
                    .padding()
                    
                }
            }.sheet(isPresented: .constant(true)) {
                ZStack {
                    Color(.secondarySystemBackground).ignoresSafeArea()
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "apple.terminal")
                                .foregroundStyle(.purple.gradient)
                                .font(.title2)
                                .padding(.leading)
                            Text("Log")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            HStack(spacing: 16) {
                                Circle()
                                    .frame(width: 12)
                                    .foregroundColor(isHandshakeComplete ? .green : .red)
                                Text(isHandshakeComplete ? "Secure Line" : "Unsecured")
                                     .font(.headline)
                                     .foregroundColor(.gray)
                            }.padding()
                                .background(Color(.systemBackground))
                                .clipShape(.capsule)
                        }.padding()
                        if currentDetent == .fraction(0.6) {
                            ScrollView {
                                Group {
                                    Text("> [App] Generating Ephemeral           Keys... OK")
                                        .bold()
                                        .fontDesign(.monospaced)
                                    
                                }.padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                            }.animation(.spring, value: currentDetent)
                        }
                    }
                }.presentationDetents([.fraction(0.1),.fraction(0.6)], selection: $currentDetent)
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.6)))
            }
        }
    }
}