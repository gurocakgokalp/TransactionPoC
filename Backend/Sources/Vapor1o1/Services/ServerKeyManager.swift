//
//  ServerKeyManager.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 2.02.2026.
//
import Vapor
import struct Foundation.UUID

final class KeyManager: @unchecked Sendable {
    static let shared = KeyManager()
    
    var serverPrivateKey: Curve25519.KeyAgreement.PrivateKey?
    
    private init() {}
    
    func createServerPrivateKey() {
        if serverPrivateKey != nil {
            print("already exist")
        } else {
            let createdKey = Curve25519.KeyAgreement.PrivateKey()
            print("key created, writing ram")
            serverPrivateKey = createdKey
        }
        
    }
    
    func getServerPrivateKey() -> Curve25519.KeyAgreement.PrivateKey? {
        if let serverPrivateKey = serverPrivateKey {
            print("key found, using due \"getServerPrivateKey()\"")
            return serverPrivateKey
        } else {
            print("no exist key.")
            return nil
        }
    }
    
}
