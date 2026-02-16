//
//  URLService.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//
import SwiftUI
import CryptoKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "http://127.0.0.1:8080/api/bank"
    
    private init() {}
    
    func post<T: Encodable, U: Decodable>(endpoint: String, body: T) async throws -> U {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("encoding error: \(error)")
            throw NetworkError.unknown
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("200 (OK) kodu donmedi")
        }
        
        do {
            let decodeResponse = try JSONDecoder().decode(U.self, from: data)
            return decodeResponse
        } catch {
            print("decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    func getStatus() async -> Bool {
        do {
            let url = URL(string: "\(baseURL)/status")!
            let (_, response) = try await URLSession.shared.data(from: url)
            let isOnline = (response as? HTTPURLResponse)?.statusCode == 200
            
            LogManager.shared.log(log: Log(who: "Server", logText: isOnline ? "server online" : "server offline", color: .primary))
            
            return isOnline
        } catch {
            print("connection failed")
            return false
        }
    }
    
    func enroll() async throws -> Bool {
        let agreementPublic = try KeyManager.shared.getAgreementPrivateKey().publicKey.rawRepresentation.base64EncodedString()
        let signingPublic = try KeyManager.shared.getSignPrivateKey().publicKey.rawRepresentation.base64EncodedString()
        let result: enrollResponse = try await post(endpoint: "enroll", body: enrollRequest(clientPublicKey: agreementPublic, clientSignPublicKey: signingPublic, deviceId: KeyManager.shared.getDeviceId().uuidString))
        if result.success {
            print("enroll success")
        }
        return result.success
    }
    
    func handshake() async throws -> handshakeResponse {
        let result: handshakeResponse = try await post(endpoint: "handshake", body: handshakeRequest(deviceId: KeyManager.shared.getDeviceId().uuidString))
        return result
    }
    
    func sendEncryptedData(req: encryptedRequest) async throws -> decryptResponse {
        let result: decryptResponse = try await post(endpoint: "receiveEncrypt", body: req)
        return result
    }
    
    
    //func encrypt() async throws -> 
    
}
