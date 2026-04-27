# AttestationServer (pleme-io fork)

> **★★★ CSE / Knowable Construction.** This repo operates under **Constructive Substrate Engineering** — canonical specification at [`pleme-io/theory/CONSTRUCTIVE-SUBSTRATE-ENGINEERING.md`](https://github.com/pleme-io/theory/blob/main/CONSTRUCTIVE-SUBSTRATE-ENGINEERING.md). The Compounding Directive (operational rules: solve once, load-bearing fixes only, idiom-first, models stay current, direction beats velocity) is in the org-level pleme-io/CLAUDE.md ★★★ section. Read both before non-trivial changes.


GrapheneOS remote attestation server. Verifies device integrity via
hardware-backed keys (Titan M2). Scheduled verification with email alerts.

## Build

```bash
nix develop                      # enter Java dev shell
./gradlew build                  # build server JAR
```

## NixOS Module

```nix
services.grapheneos-attestation = {
  enable = true;
  domain = "attestation.example.com";
  port = 8085;
  emailAlerts = true;
};
```

## Upstream

Forked from [GrapheneOS/AttestationServer](https://github.com/GrapheneOS/AttestationServer).
MIT license. Sync: `git fetch upstream && git merge upstream/main`.

## Integration

- NixOS module for deployment on pleme-io K3s nodes
- `andro-gos` crate's `AttestationVerifier` trait connects to this server
- Future: tameshi integration (attestation as BLAKE3 Merkle tree layer)
