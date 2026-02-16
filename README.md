# Transaction Simulation

TransactionPoC is a security-focused proof of concept built to explore **End-to-End Encryption (E2EE)** and **hardware-backed signing** in a mobile client–server setup.  
The project aims to demonstrate how sensitive transaction data can be protected using modern cryptographic primitives and platform security features.

## Project Demo

https://github.com/user-attachments/assets/b8e02c1e-19f4-4b64-af27-ee3775d5ceb5

## Cryptographic Primitives

- **Signing:** `P256` key pair generated and stored in the Secure Enclave
- **Key Agreement:** `Curve25519` for ephemeral ECDH handshake
- **Encryption:** `AES-GCM` for authenticated encryption
- **Key Derivation:** `HKDF (SHA-256)` for deriving session keys

## System Flow

1. **Enrollment:** The iOS app generates a persistent `P256` key pair inside the Secure Enclave.
2. **Handshake:** Client and server exchange ephemeral `Curve25519` public keys.
3. **Derivation:** A symmetric session key is derived using HKDF.
4. **Encryption:** Transaction payloads are encrypted using AES-GCM.
5. **Signing:** Encrypted transfers are signed using the hardware-bound private key.

## How to Run

**1. Start the Backend**
```bash
cd Backend
swift run
```
**2. Run the iOS App**
Open `iOS/TransactionPoC.xcodeproj`, check the NetworkManager URL, and run on a Simulator.

## Known Limitations
- **Thread Safety:** The backend utilizes `@unchecked Sendable` on the in-memory storage for simplicity. It is not thread-safe and would require `Actor` isolation in a production environment.
- **Storage:** Keys are stored in RAM and will be lost if the server restarts.
