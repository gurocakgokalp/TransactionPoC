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
        
        
        KeyManager.shared.createServerPrivateKey()
    }
    
    func receiveEncryptedRequest(req: Request) async throws -> decryptResponse {
        let input = try req.content.decode(encryptedRequest.self)
        do {
            let sealedBox = try CryptoHelper.shared.createSealedBox(nonce: input.nonce, tag: input.tag, ciphertext: input.ciphertext)
            
            guard let sealedBoxS = sealedBox.combined?.base64EncodedString() else {
                throw CryptoError.b64encoding
            }
            let verifyResult = try CryptoHelper.shared.verify(signatureS: input.signature, originalDataS: sealedBoxS, deviceId: input.deviceID)
            
            if verifyResult {
                let decryptedData = try CryptoHelper.shared.decrypt(sealedBox: sealedBox, deviceID: input.deviceID)
                
                let transaction = try JSONDecoder().decode(transactionRequest.self, from: decryptedData)
                
                let now = Int64(Date().timeIntervalSince1970)
                guard abs(now - transaction.timestamp) < 300 else {
                    print("replay attack: stale timestamp")
                    throw Abort(.badRequest, reason: "Request expired")
                }
                
                guard await NonceStore.shared.checkAndInsert(transaction.replayNonce) else {
                    print("replay attack: duplicate nonce")
                    throw Abort(.badRequest, reason: "Duplicate request")
                }
                
                //normalde burda iste db bagli olacak para atanacak cart curt...
                print("\(transaction.id) id, \(transaction.amount) lira degerindeki islem onaylandi. payload:\n\namount: \(transaction.amount) TL\ndesc: \(transaction.desc)\nalici iban: TR\(transaction.iban)\nuuid: \(transaction.id)")
                
                
                return decryptResponse(status: "OK.", message: "decrypted payload:\n \namount: \(transaction.amount) TL\ndesc: \(transaction.desc)\nalici iban: TR\(transaction.iban)\nuuid: \(transaction.id)")
            } else {
                return decryptResponse(status: "failed.", message: "imza dogrulamasi yapilmadi. etc. dosya degistirilmis.")
            }
        } catch CryptoError.b64decoding {
            return decryptResponse(status: "failed.", message: "base64 decoding error")
        } catch CryptoError.b64encoding {
            return decryptResponse(status: "failed.", message: "base64 encoding error")
        } catch CryptoError.sealedBoxCreating(let err) {
            return decryptResponse(status: "failed.", message: "something went wrong when sealedbox creating: \(err)")
        } catch CryptoError.dbAccess {
            return decryptResponse(status: "failed.", message: "something went wrong when trying store")
        }
        catch {
            return decryptResponse(status: "failed.", message: "unknown error: \(error.localizedDescription)")
        }
        
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

