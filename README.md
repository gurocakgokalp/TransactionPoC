# SecureTransfer iOS

A security-focused iOS + Vapor proof of concept simulating encrypted financial 
transactions. Demonstrates E2EE architecture with hardware-backed signing, 
ephemeral key agreement, and replay attack prevention.

## Project Demo

https://github.com/user-attachments/assets/b8e02c1e-19f4-4b64-af27-ee3775d5ceb5

## Cryptographic Primitives

- **Signing:** `P256` key pair generated and stored in the Secure Enclave
- **Key Agreement:** `Curve25519` for ephemeral ECDH handshake
- **Encryption:** `AES-GCM` for authenticated encryption
- **Key Derivation:** `HKDF (SHA-256)` for deriving session keys
- **Replay Prevention** `UUID nonce + 300s` timestamp window

## System Flow

1. **Enrollment** — iOS generates a persistent `P256` key pair inside the 
Secure Enclave. Public key is registered with the server.
2. **Handshake** — Client and server exchange ephemeral `Curve25519` public 
keys and derive a shared symmetric key via HKDF.
3. **Encryption** — Transaction payload is sealed with `AES-GCM` before 
leaving the device.
4. **Signing** — The encrypted payload is signed with the hardware-bound 
P256 private key.
5. **Verification** — Server verifies the ECDSA signature, validates the 
nonce and timestamp, then decrypts and approves the transaction.

## Replay Attack Prevention

Each transaction payload includes a unique `replayNonce` (UUID) and a 
`timestamp`. The server rejects any request where:

- The nonce has already been seen → `[ WARNING ] Replay attack: duplicate nonce [nonce: A1B1..., device_id: 934D...]`
- The timestamp is outside the 300-second window → `[ WARNING ] Replay attack: stale timestamp [nonce: A1B1...]`

## Running with Docker
```bash
cd Backend
docker compose up
```

Then open `iOS/TransactionPoC.xcodeproj` and run on Simulator.

## Tech Stack

- **iOS:** Swift, SwiftUI, CryptoKit, LocalAuthentication, Secure Enclave
- **Backend:** Vapor (Server-side Swift), Docker

## Known Limitations
- Thread safety: `BankStore` uses `@unchecked Sendable` — would require 
Actor isolation in production.
- Nonce cache and session keys are held in RAM and lost on server restart.

> **Disclaimer:** Educational and portfolio use only. Not audited. 
