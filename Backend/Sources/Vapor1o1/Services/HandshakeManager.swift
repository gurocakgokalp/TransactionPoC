//
//  HandshakeManager.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 16.02.2026.
//
import Vapor

final class HandshakeManager: @unchecked Sendable {
    static let shared = HandshakeManager()
    private let logger = Logger(label: "handshake.manager")
    
    private init() {}
    
    
    func handshake(deviceId: String) -> handshakeResponse {
        guard let serverPrivateKey = KeyManager.shared.getServerPrivateKey() else {
            logger.critical("Server private key not found")
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: "No exist server-private-key.")
        }
        
        guard let clientPublicKeyString = BankStore.shared.database[deviceId]?.clientAgreementPublicKey else {
            logger.error("Client agreement key not found", metadata: ["device_id": .string(deviceId)])
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: "Cannot access client-agreement-key from db.")
        }
        //print("received ios(client) client public agreement key: \(clientPublicKeyString)")
        
        guard let clientPublicKeyRawData = Data(base64Encoded: clientPublicKeyString) else {
            logger.error("Base64 decode failed", metadata: ["context": "clientPublicKey", "device_id": .string(deviceId)])
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: "no exist client public key raw data.")
        }
        do {
            let clientPublicKey = try CryptoHelper.shared.restoreAgreementPublicKey(rawRepresentation: clientPublicKeyRawData)
            
            let salt = CryptoHelper.shared.generateRandomSalt()
            
            let sharedSecret = try serverPrivateKey.sharedSecretFromKeyAgreement(with: clientPublicKey)
            let symmetricKey = CryptoHelper.shared.generateHkdfDerivedSymmetricKey(sharedSec: sharedSecret, salt: salt)
            
            BankStore.shared.database[deviceId]?.sharedSessionKey = symmetricKey
            
            logger.info("Handshake completed", metadata: ["device_id": .string(deviceId)])
            
            return handshakeResponse(serverPublicKey: serverPrivateKey.publicKey.rawRepresentation.base64EncodedString(), status: "OK", salt: salt.base64EncodedString(), message: "everything looks fine.")
        } catch {
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: error.localizedDescription)
        }
        
    }
}

