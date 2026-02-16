//
//  KeyManager.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//
import CryptoKit
import LocalAuthentication
import SwiftUI

class KeyManager {
    static let shared = KeyManager()
    
    private var signingPrivateKey: SecureEnclave.P256.Signing.PrivateKey?
    private var agreementPrivateKey: Curve25519.KeyAgreement.PrivateKey?
    
    private var deviceId: UUID?
    
    let keySignTag = "com.gokalpgurocak.transactionPoC.signing"
    let keyAgreementTag = "com.gokalpgurocak.transactionPoC.agreement"
    let deviceIdTag = "com.gokalpgurocak.transactionPoC.deviceId"

    private init() {}
    
    func getSignPrivateKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
        if let signingPrivateKey = signingPrivateKey {
            return signingPrivateKey
        }
        
        if let savedData = loadKeyDataFromKeychain(keyTag: keySignTag) {
            do {
                let restoredKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: savedData)
                self.signingPrivateKey = restoredKey
                LogManager.shared.log(log: Log(who: "KeyManager", logText: "sign key restored", color: .primary))
                print("sign key restored.")
                return restoredKey
            } catch {
                LogManager.shared.log(log: Log(who: "KeyManager", logText: "key cannot restore.", color: .primary))
                print("key cannot restore.")
            }
        }
        
        //enroll gerekecek
        LogManager.shared.log(log: Log(who: "KeyManager", logText: "new signiing private key creating...", color: .primary))
        print("new signiing private key creating...")
        return try createAndSaveNewSignKey()
    }
    
    func createAndSaveNewSignKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
        var error: Unmanaged<CFError>?
        let context = LAContext()
        
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage],
            &error
        ) else {
            throw KeyError.accessControlError
        }
        let createdKey = try SecureEnclave.P256.Signing.PrivateKey(compactRepresentable: false, accessControl: access, authenticationContext: context)
        
        saveKeyDataKeychain(data: createdKey.dataRepresentation, keyTag: keySignTag)
        
        self.signingPrivateKey = createdKey
        return createdKey
    }
    
    func getAgreementPrivateKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        if let agreementKey = agreementPrivateKey {
            return agreementKey
        }
        
        if let savedData = loadKeyDataFromKeychain(keyTag: keyAgreementTag) {
            do {
                let restoredKey = try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: savedData)
                print("agreement key restored")
                LogManager.shared.log(log: Log(who: "KeyManager", logText: "agreement key restored", color: .primary))
                self.agreementPrivateKey = restoredKey
                return restoredKey
            } catch {
                LogManager.shared.log(log: Log(who: "KeyManager", logText: "cannot restore agreement key", color: .primary))
                print("cannot restore agreement key")
            }
        }
        LogManager.shared.log(log: Log(who: "KeyManager", logText: "new agreement key creating...", color: .primary))
        print("new agreement key creating...")
        return try createAndSaveNewAgreementKey()
    }
    
    func createAndSaveNewAgreementKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        let createdKey = Curve25519.KeyAgreement.PrivateKey()
        
        saveKeyDataKeychain(data: createdKey.rawRepresentation, keyTag: keyAgreementTag)
        self.agreementPrivateKey = createdKey
        LogManager.shared.log(log: Log(who: "KeyManager", logText: "agreement key created", color: .primary))
        print("agreement key created.")
        return createdKey
    }
    
    func getDeviceId() throws -> UUID {
        if let deviceId = deviceId {
            return deviceId
        }
        
        if let savedData = loadKeyDataFromKeychain(keyTag: deviceIdTag) {
            guard let uuidString = String(data: savedData, encoding: .utf8) else {
                print("something went wrong when restore deviceId")
                throw KeyError.restoreError
            }
            guard let uuid = UUID(uuidString: uuidString) else {
                print("something went wrong when restore deviceId")
                throw KeyError.restoreError
            }
            print("deviceId restored")
            return uuid
        }
        print("no exist id, creating new one")
        return try createAndSaveDeviceId()
    }
    
    func createAndSaveDeviceId() throws -> UUID {
        let createdId = UUID()
        let idData = Data(createdId.uuidString.utf8)
        
        saveKeyDataKeychain(data: idData, keyTag: deviceIdTag)
        self.deviceId = createdId
        print("device id generated.")
        return createdId
    }
    
}

