//
//  CryptoHelper.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 4.02.2026.
//
import Vapor

final class CryptoHelper: @unchecked Sendable {
    static let shared = CryptoHelper()
    private let logger = Logger(label: "crypto.helper")
    
    private init() {}
    
    func verify(signatureS: String, originalDataS: String, deviceId: String) throws -> Bool {
        guard let originalData = Data(base64Encoded: originalDataS) else {
            logger.error("B64 decode failed", metadata: ["context": "originalData", "deviceId": .string(deviceId)])
            throw CryptoError.b64decoding
        }
        
        guard let signatureD = Data(base64Encoded: signatureS) else {
            logger.error("Base64 decode failed", metadata: ["context": "signatureD", "device_id": .string(deviceId)])
            throw CryptoError.b64decoding
        }
        
        
        guard let clientSigningPublicKeyString = BankStore.shared.database[deviceId]?.clientSignPublicKey else {
            logger.error("Public key not found in store", metadata: ["device_id": .string(deviceId)])
            throw CryptoError.dbAccess
        }
        guard let clientPublicData = Data(base64Encoded: clientSigningPublicKeyString) else {
            logger.error("Base64 decode failed", metadata: ["context": "publicKey", "device_id": .string(deviceId)])
            throw CryptoError.b64decoding
        }
        // iosta secure enclave idi key ama burda normal p256 bakalim ne olacak.
        let clientSignPublicKey = try P256.Signing.PublicKey(rawRepresentation: clientPublicData)
        
        let signature = try P256.Signing.ECDSASignature(rawRepresentation: signatureD)
        
        let verifyResult = clientSignPublicKey.isValidSignature(signature, for: originalData)
        
        if verifyResult {
            logger.debug("Signature verified", metadata: ["device_id": .string(deviceId)])
        } else {
            logger.warning("Signature invalid", metadata: ["device_id": .string(deviceId)])
        }
        
        return verifyResult
    }
    
    func decrypt(sealedBox: AES.GCM.SealedBox, deviceID: String) throws -> Data {
        guard let sharedSKey = BankStore.shared.database[deviceID]?.sharedSessionKey else {
            logger.error("Session key not found", metadata: ["device_id": .string(deviceID)])
            throw CryptoError.dbAccess
        }
        do {
            let result = try AES.GCM.open(sealedBox, using: sharedSKey)
            logger.debug("Decryption successful", metadata: ["device_id": .string(deviceID)])
            return result
        } catch {
            logger.error("Decryption failed", metadata: [
                "device_id": .string(deviceID),
                "reason": .string(error.localizedDescription)
            ])
            throw error
        }
    }
    
    func createSealedBox(nonce: String, tag: String, ciphertext: String) throws -> AES.GCM.SealedBox {
        guard let ciphertext = Data(base64Encoded: ciphertext) else {
            logger.error("Base64 decode failed", metadata: ["context": "ciphertext"])
            throw CryptoError.b64decoding
        }
        guard let nonceD = Data(base64Encoded: nonce) else {
            logger.error("Base64 decode failed", metadata: ["context": "nonce"])
            throw CryptoError.b64decoding
        }
        let nonce = try AES.GCM.Nonce(data: nonceD)
        guard let tag = Data(base64Encoded: tag) else {
            logger.error("Base64 decode failed", metadata: ["context": "tag"])
            throw CryptoError.b64decoding
        }
        do {
            return try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        } catch let err {
            logger.error("SealedBox creation failed", metadata: ["reason": .string(err.localizedDescription)])
            throw CryptoError.sealedBoxCreating(err.localizedDescription)
        }
    }
    
    func restoreAgreementPublicKey(rawRepresentation: Data) throws -> Curve25519.KeyAgreement.PublicKey {
        return try Curve25519.KeyAgreement.PublicKey(rawRepresentation: rawRepresentation)
    }
    
    func generateHkdfDerivedSymmetricKey(sharedSec: SharedSecret, salt: Data) -> SymmetricKey {
        return sharedSec.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data("e2ee".utf8), outputByteCount: 32)
    }
    
    func generateRandomSalt() -> Data {
        return SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
    }
}

