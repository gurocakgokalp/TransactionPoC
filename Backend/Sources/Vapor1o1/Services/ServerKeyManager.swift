//
//  ServerKeyManager.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 2.02.2026.
//
import Vapor
import struct Foundation.UUID

// configure.swift de cagirmak gerekiyor, her yerden cagirilabilir suan risk var. app.lifecycle kullanilmali
final class KeyManager: @unchecked Sendable {
    static let shared = KeyManager()
    private let logger = Logger(label: "key.manager")
    
    private var serverPrivateKey: Curve25519.KeyAgreement.PrivateKey?
    
    private init() {}
    
    func createServerPrivateKey() {
        if serverPrivateKey != nil {
            logger.warning("Server private key already exists, skipping creation")
        } else {
            let createdKey = Curve25519.KeyAgreement.PrivateKey()
            logger.info("Server private key created")
            serverPrivateKey = createdKey
        }
        
    }
    
    func getServerPrivateKey() -> Curve25519.KeyAgreement.PrivateKey? {
        if let serverPrivateKey = serverPrivateKey {
            //print("key found, using due \"getServerPrivateKey()\"")
            return serverPrivateKey
        } else {
            logger.critical("Server private key requested but not found")
            return nil
        }
    }
    
}
