//
//  AuthManager.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 6.02.2026.
//
import SwiftUI
import Combine
import CryptoKit

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @AppStorage("isEnrolled") var isEnrolled: Bool = false
    private var sharedKey: SymmetricKey?
    @Published var isHandshaked: Bool = false
    @Published var serverStatus: Bool = false
    
    private init() {}
    
    func appBoot() async {
        await checkServerStatus()
        if serverStatus {
            if !isEnrolled {
                do {
                    let isSuccess = try await NetworkManager.shared.enroll()
                    if isSuccess {
                        isEnrolled = true
                        LogManager.shared.log(log: Log(who: "AuthManager", logText: "enrollment succesfully", color: .green))
                    }
                } catch {
                    LogManager.shared.log(log: Log(who: "AuthManager", logText: "enrollment failed: \(error.localizedDescription)", color: .red))
                    return
                }
            } else {
                LogManager.shared.log(log: Log(who: "AuthManager", logText: "already exist enrollment", color: .primary))
            }
            
            await handshake()
        } else {
            LogManager.shared.log(log: Log(who: "AuthManager", logText: "cannot access server", color: .green))
            /*
             - normalde false etmemem gerekiyor.
             - ancak server restart edildiginde veriler gittigi icin (ramde tutuluyor), enroll islemini yeniden yapmam gerekiyor.
             - poc oldugu icin server ustune fazla gitmedim.
             */
            isEnrolled = false
        }
    }
    
    func checkServerStatus() async {
        serverStatus = await NetworkManager.shared.getStatus()
    }
    
    private func handshake() async {
        do {
            let handshakeResponse = try await NetworkManager.shared.handshake()
            if handshakeResponse.status == "OK" {
                LogManager.shared.log(log: Log(who: "Server", logText: "handshake successfully.", color: .green))
                sharedKey = try CryptoManager.shared.handshake(serverPublicKeyS: handshakeResponse.serverPublicKey, saltS: handshakeResponse.salt)
                isHandshaked = true
            } else if handshakeResponse.status == "FAILED" {
                LogManager.shared.log(log: Log(who: "Server", logText: "handshake failed due server", color: .red))
                isHandshaked = false
            }
        } catch {
            print("handshake failed: \(error.localizedDescription)")
            LogManager.shared.log(log: Log(who: "AuthManager", logText: "handshake failed: \(error.localizedDescription)", color: .red))
            isHandshaked = false
            return
        }
    }
    
    func getUserRequestAndEncrypt(transaction: transactionRequest) async {
        if let sharedKey = sharedKey {
            do {
                LogManager.shared.log(log: Log(who: "AuthManager", logText: "sending encrypted data...", color: .primary))
                let request = try CryptoManager.shared.encrypt(transaction: transaction, sharedKey: sharedKey)
                let response = try await NetworkManager.shared.sendEncryptedData(req: request)
                if response.status == "OK." {
                    LogManager.shared.log(log: Log(who: "Server", logText: response.message, color: .green))
                } else {
                    LogManager.shared.log(log: Log(who: "Server", logText: response.message, color: .red))
                }
                
            } catch {
                print("err0r: \(error.localizedDescription)")
                LogManager.shared.log(log: Log(who: "AuthManager", logText: "something went wrong when encryption: \(error.localizedDescription)", color: .red))
            }
        } else {
            print("no exist sharedkey")
            LogManager.shared.log(log: Log(who: "AuthManager", logText: "no exist sharedKey", color: .red))
        }
    }
    
}

