//
//  TransactionService.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 29.03.2026.
//
import Vapor

final class TransactionService: @unchecked Sendable {
    static let shared = TransactionService()
    private init() {}
    
    func process(request: encryptedRequest, logger: Logger) async throws -> transactionRequest {
        let sealedBox = try CryptoHelper.shared.createSealedBox(nonce: request.nonce, tag: request.tag, ciphertext: request.ciphertext)
        
        guard let sealedBoxS = sealedBox.combined?.base64EncodedString() else {
            throw CryptoError.b64encoding
        }
        
        let isValid = try CryptoHelper.shared.verify(signatureS: request.signature, originalDataS: sealedBoxS, deviceId: request.deviceID)
        
        guard isValid else {
            logger.warning("Signature verification failed", metadata: ["device_id": .string(request.deviceID)])
            throw Abort(.unauthorized, reason: "Invalid signature")
        }
        
        let decryptedData = try CryptoHelper.shared.decrypt(sealedBox: sealedBox, deviceID: request.deviceID)
        
        let transaction = try JSONDecoder().decode(transactionRequest.self, from: decryptedData)
        
        let now = Int64(Date().timeIntervalSince1970)
        guard abs(now - transaction.timestamp) < 300 else {
            logger.warning("Replay attack: stale timestamp", metadata: ["nonce": .string(transaction.replayNonce)])
            throw Abort(.badRequest, reason: "Request expired")
        }
        
        guard await NonceStore.shared.checkAndInsert(transaction.replayNonce) else {
            logger.warning("Replay attack: duplicate nonce", metadata: ["nonce": .string(transaction.replayNonce)])
            throw Abort(.badRequest, reason: "Duplicate request")
        }
        
        return transaction
    }
}
