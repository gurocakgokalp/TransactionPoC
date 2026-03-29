//
//  VaultController.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 2.02.2026.
//
import Vapor
import Fluent

struct BankController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        // burada url destegi yapiyoruz. /api/bank/... gibi
        let bank = routes.grouped("api", "bank")
        
        ///api/bank/handshake
        bank.get("status", use: status)
        bank.post("handshake", use: handshake)
        bank.post("enroll", use: enroll)
        bank.post("transfer", use: receiveEncryptedRequest)
    }
    
    func receiveEncryptedRequest(req: Request) async throws -> decryptResponse {
        let input = try req.content.decode(encryptedRequest.self)
        let transaction = try await TransactionService.shared.process(request: input, logger: req.logger)
        
        req.logger.info("Transaction approved", metadata: [
            "transaction_id": .string(transaction.id.uuidString),
            "amount": "\(transaction.amount)",
            "beneficiary_iban": "\(transaction.iban)",
            "device_id": .string(input.deviceID)
        ])
        
        return decryptResponse(status: "OK", message: "Transaction approved.")
        
    }
    
    func status(req: Request) async throws -> HTTPStatus {
        return .ok
    }
    
    func handshake(req: Request) async throws -> handshakeResponse {
        let input = try req.content.decode(handshakeRequest.self)
        let response = HandshakeManager.shared.handshake(deviceId: input.deviceId)
        
        return response
    }
    
    //normalde direkt status döndürecektim ama ios tarafında ekstra func yazmam gerekiyor. enrollresponse olusturucam onun yerine.
    func enroll(req: Request) async throws -> enrollResponse {
        let input = try req.content.decode(enrollRequest.self)
        BankStore.shared.database.updateValue(UserSession(clientAgreementPublicKey: input.clientPublicKey, clientSignPublicKey: input.clientSignPublicKey), forKey: input.deviceId)
        return enrollResponse(success: true, message: "success")
    }
    
}

