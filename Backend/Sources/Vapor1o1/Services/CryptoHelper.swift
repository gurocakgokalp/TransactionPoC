//
//  CryptoHelper.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 4.02.2026.
//
import Vapor

final class CryptoHelper: @unchecked Sendable {
    static let shared = CryptoHelper()
    
    private init() {}
    
    func verify(signatureS: String, originalDataS: String, deviceId: String) throws -> Bool {
        guard let originalData = Data(base64Encoded: originalDataS) else {
            throw CryptoError.b64decoding
        }
        
        guard let signatureD = Data(base64Encoded: signatureS) else {
            throw CryptoError.b64decoding
        }
        
        
        guard let clientSigningPublicKeyString = BankStore.shared.database[deviceId]?.clientSignPublicKey else {
            throw CryptoError.dbAccess
        }
        guard let clientPublicData = Data(base64Encoded: clientSigningPublicKeyString) else {
            throw CryptoError.b64decoding
        }
        // iosta secure enclave idi key ama burda normal p256 bakalim ne olacak.
        let clientSignPublicKey = try P256.Signing.PublicKey(rawRepresentation: clientPublicData)
        
        let signature = try P256.Signing.ECDSASignature(rawRepresentation: signatureD)
        
        let verifyResult = clientSignPublicKey.isValidSignature(signature, for: originalData)
        
        print("verify result: \(verifyResult)")
        return verifyResult
    }
    
    func decrypt(sealedBox: AES.GCM.SealedBox, deviceID: String) throws -> Data {
        guard let sharedSKey = BankStore.shared.database[deviceID]?.sharedSessionKey else {
            return Data()
        }
        return try AES.GCM.open(sealedBox, using: sharedSKey)
    }
    
    func createSealedBox(nonce: String, tag: String, ciphertext: String) throws -> AES.GCM.SealedBox {
        guard let ciphertext = Data(base64Encoded: ciphertext) else {
            throw CryptoError.b64decoding
        }
        guard let nonceD = Data(base64Encoded: nonce) else {
            throw CryptoError.b64decoding
        }
        let nonce = try AES.GCM.Nonce(data: nonceD)
        guard let tag = Data(base64Encoded: tag) else {
            throw CryptoError.b64decoding
        }
        do {
            return try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        } catch let err {
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

