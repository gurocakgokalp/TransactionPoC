//
//  HandshakeManager.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 16.02.2026.
//
import Foundation

final class HandshakeManager: @unchecked Sendable {
    static let shared = HandshakeManager()
    
    private init() {}
    
    
    func handshake(deviceId: String) -> handshakeResponse {
        guard let serverPrivateKey = KeyManager.shared.getServerPrivateKey() else {
            print("no exist server-private")
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: "No exist server-private-key.")
        }
        
        guard let clientPublicKeyString = BankStore.shared.database[deviceId]?.clientAgreementPublicKey else {
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: "Cannot access client-agreement-key from db.")
        }
        print("received ios(client) client public agreement key: \(clientPublicKeyString)")
        
        guard let clientPublicKeyRawData = Data(base64Encoded: clientPublicKeyString) else {
            print("no exist client public key raw data.")
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: "no exist client public key raw data.")
        }
        do {
            let clientPublicKey = try CryptoHelper.shared.restoreAgreementPublicKey(rawRepresentation: clientPublicKeyRawData)
            
            let salt = CryptoHelper.shared.generateRandomSalt()
            
            let sharedSecret = try serverPrivateKey.sharedSecretFromKeyAgreement(with: clientPublicKey)
            let symmetricKey = CryptoHelper.shared.generateHkdfDerivedSymmetricKey(sharedSec: sharedSecret, salt: salt)
            
            BankStore.shared.database[deviceId]?.sharedSessionKey = symmetricKey
            
            return handshakeResponse(serverPublicKey: serverPrivateKey.publicKey.rawRepresentation.base64EncodedString(), status: "OK", salt: salt.base64EncodedString(), message: "everything looks fine.")
        } catch {
            return handshakeResponse(serverPublicKey: "", status: "FAILED", salt: "", message: error.localizedDescription)
        }
        
    }
}

