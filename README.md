# TransactionPoC

TransactionPoC is a secure mobile banking simulation built to explore **End-to-End Encryption (E2EE)** and **Hardware-Backed Transaction Signing**. The goal was to create a "trustless" communication channel between an iOS client and a server where sensitive data is protected by hardware security.

## Project Demo

https://github.com/user-attachments/assets/b8e02c1e-19f4-4b64-af27-ee3775d5ceb5

## Cryptographic Primitives

* **Signing:** `P256` (NIST P-256) inside Secure Enclave.
* **Key Agreement:** `Curve25519` for ephemeral handshake.
* **Encryption:** `AES-GCM` for authenticated encryption.
* **Key Derivation:** `HKDF` (SHA-256) for deriving session keys.

## System Flow

1.  **Enrollment:** The app generates a permanent `P256` key pair in the Secure Enclave.
2.  **Handshake:** Client and Server exchange ephemeral `Curve25519` keys to perform ECDH.
3.  **Derivation:** Using **HKDF**, a symmetric session key is derived from the shared secret.
4.  **Encryption:** Transaction data is encrypted using **AES-GCM**.
5.  **Signing:** Transfers are cryptographically signed using the hardware-bound `P256` private key.

## How to Run

**1. Start the Backend**
```bash
cd Backend
swift run
```
**2. Run the iOS App**
Open iOS/TransactionPoC.xcodeproj, check the NetworkManager URL, and run on a Simulator.

## Known Limitations
- **Thread Safety:** The backend utilizes @unchecked Sendable on the in-memory storage for simplicity. It is not thread-safe and would require Actor isolation in a production environment.
- **Storage:** Keys are stored in RAM and will be lost if the server restarts.
