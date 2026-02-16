//
//  ContentView.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 4.02.2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var currentDetent: PresentationDetent = .fraction(0.1)
    @State private var isHandshakeComplete: Bool = true
    @State private var isEnrolled: Bool = false
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var logManage = LogManager.shared
    
    @State var amount: String = ""
    @State var desc: String = ""
    @State var iban: String = ""
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
                        HStack {
                            HStack {
                                Circle()
                                    .fill(authManager.isEnrolled ? .green:.red)
                                    .frame(width: 10)
                                Text(authManager.isEnrolled ? "Key Enrolled" : "Not Enrolled")
                                    .font(.caption)
                            }.padding(.vertical, 4)
                                .padding(.horizontal)
                                .background(Capsule().fill(Color(.systemBackground)))
                            HStack {
                                Circle()
                                    .fill(authManager.isHandshaked ? .green:.red)
                                    .frame(width: 10)
                                Text(authManager.isHandshaked ? "Connected ": "Disconnected")
                                    .font(.caption)
                            }.padding(.vertical, 4)
                                .padding(.horizontal)
                                .background(Capsule().fill(Color(.systemBackground)))
                            HStack {
                                Circle()
                                    .fill(authManager.serverStatus ? .green:.red)
                                    .frame(width: 10)
                                Image(systemName: "server.rack")
                                    .font(.caption)
                            }.padding(.vertical, 4)
                                .padding(.horizontal)
                                .background(Capsule().fill(Color(.systemBackground)))
                        }
                    }
                    //
                    VStack(spacing: 12){
                        HStack {
                            Image(systemName: "turkishlirasign")
                                .frame(width: 30)
                            
                            TextField("Transaction amount", text: $amount)
                                .keyboardType(.asciiCapable)
                                .textInputAutocapitalization(.characters)
                                .onChange(of: amount) { _ , newValue in
                                    let allowed = "0123456789"
                                    amount = String(
                                        newValue
                                            .uppercased()
                                            .filter { allowed.contains($0) }
                                            .prefix(6)
                                    )
                                }
                        }
                        Divider()
                        
                        //basta tr olacak
                        HStack {
                            Image(systemName: "building.columns")
                                .frame(width: 30)
                            if iban.count != 0 {
                                Text("TR")
                            }
                            TextField("IBAN", text: $iban)
                                .keyboardType(.asciiCapable)
                                .textInputAutocapitalization(.characters)
                                .onChange(of: iban) { _ , newValue in
                                    let allowed = "0123456789"
                                    iban = String(
                                        newValue
                                            .uppercased()
                                            .filter { allowed.contains($0) }
                                            .prefix(24)
                                    )
                                    
                                }
                            if iban.count == 0 {
                                Button {
                                    if let iban = UIPasteboard.general.string {
                                        self.iban = iban
                                    }
                                } label: {
                                    Image(systemName: "doc.on.clipboard")

                                }

                            }
                        }
                        Divider()
                        HStack {
                            Image(systemName: "text.alignleft")
                                .frame(width: 30)
                            TextField("Description", text: $desc)
                                .keyboardType(.default)
                
                        }
                        
                    }.padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .padding()
                    //
                    

                    Button(action: {
                        Task {
                            await setupTransaction()
                        }
                        withAnimation {
                            currentDetent = .fraction(0.6)
                        }
                    }) {
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
                    .disabled(iban.isEmpty || desc.isEmpty || amount.isEmpty)
                    
                }
            }.task {
                await authManager.appBoot()
            }
            .sheet(isPresented: .constant(true)) {
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
                            if currentDetent == .fraction(0.6) {
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundStyle(.purple.gradient)

                                Text("Clear Log")
                                    .bold()
                                    .padding(.trailing)
                                    .foregroundStyle(.purple.gradient)
                                    .onTapGesture {
                                        logManage.clearLog()
                                    }


                            }
                        }.padding()
                        if currentDetent == .fraction(0.6) {
                            if logManage.logs.count != 0 {
                                ScrollView {
                                    Group {
                                        ForEach(logManage.logs) { log in
                                            HStack {
                                                Text("[\(log.who)] \(log.logText)")
                                                    .font(.system(.caption, design: .monospaced))
                                                //.foregroundStyle(log.color)
                                                Spacer()
                                            }
                                        }
                                        
                                    }.padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        )
                                        .padding(.horizontal)
                                }.animation(.spring, value: currentDetent)
                            } else {
                                ContentUnavailableView("It seems clear.", systemImage: "tray")
                            }
                        }
                    }
                }.presentationDetents([.fraction(0.1),.fraction(0.6)], selection: $currentDetent)
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.6)))
            }
        }
    }
    
    func setupTransaction() async {
        //LogManager.shared.clearLog()
        await authManager.checkServerStatus()
        if authManager.serverStatus {
            LogManager.shared.log(log: Log(who: "View", logText: "setting up transaction...", color: .primary))
            guard let amountDouble = Double(self.amount) else {
                LogManager.shared.log(log: Log(who: "View", logText: "something went wrong when converting amount from String to Double", color: .red))
                return
            }
            await authManager.getUserRequestAndEncrypt(transaction: transactionRequest(amount: amountDouble, iban: self.iban, desc: desc))
        } else {
            LogManager.shared.log(log: Log(who: "View", logText: "server offline, transaction canceled...", color: .primary))
        }
    }
    
    
}


#Preview {
    ContentView()
        .tint(.purple)
}
