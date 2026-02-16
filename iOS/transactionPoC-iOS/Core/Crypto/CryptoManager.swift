//
//  CryptoManager.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//
import SwiftUI
import CryptoKit

class CryptoManager {
    static let shared = CryptoManager()
    
    private init() {}
    
    func handshake(serverPublicKeyS: String, saltS: String) throws -> SymmetricKey {
        guard let salt = Data(base64Encoded: saltS) else {
            throw CryptoError.b64decoding
        }
        guard let serverPublicKeyData = Data(base64Encoded: serverPublicKeyS) else {
            throw CryptoError.b64decoding
        }
        let serverPublicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: serverPublicKeyData)
        
        let clientPrivateKey = try KeyManager.shared.getAgreementPrivateKey()
        do {
            let sharedSecret = try clientPrivateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)
            return sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data("e2ee".utf8), outputByteCount: 32)
        } catch {
            throw CryptoError.error(error.localizedDescription)
        }
    }
    
    func encrypt(transaction: transactionRequest, sharedKey: SymmetricKey) throws -> encryptedRequest {
        let jsonData = try JSONEncoder().encode(transaction)
        
        let sealedBox = try AES.GCM.seal(jsonData, using: sharedKey)
        let deviceId = try KeyManager.shared.getDeviceId().uuidString
        
        guard let digest = sealedBox.combined else {
            throw CryptoError.combinedMissing
        }
        
        let signature = try sign(digest: digest)
        
        
        return encryptedRequest(ciphertext: sealedBox.ciphertext.base64EncodedString(), signature: signature.rawRepresentation.base64EncodedString(), nonce: sealedBox.nonce.withUnsafeBytes { Data($0)}.base64EncodedString(), tag: sealedBox.tag.base64EncodedString(), deviceID: deviceId)
    }
    
    func sign(digest: Data) throws -> P256.Signing.ECDSASignature {
        let signPrivateKey = try KeyManager.shared.getSignPrivateKey()
        return try signPrivateKey.signature(for: digest)
    }
    
}
