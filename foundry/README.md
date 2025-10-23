# Merkle Airdrop

A secure and gas-efficient smart contract system for distributing ERC20 tokens via Merkle tree-based airdrops with EIP-712 signature support.

## Overview

This project implements a Merkle tree-based airdrop mechanism that allows eligible users to claim tokens by providing valid Merkle proofs. The system supports gas-efficient claiming through EIP-712 typed signatures, enabling third-party gas payers to submit claims on behalf of users.

### Key Features

- **Merkle Proof Verification**: Uses Merkle trees to efficiently verify eligibility without storing all eligible addresses on-chain
- **EIP-712 Signature Support**: Allows users to sign claims off-chain, enabling meta-transactions where someone else pays the gas
- **Double-Claim Prevention**: Tracks claimed addresses to prevent duplicate claims
- **Gas Efficient**: Minimizes on-chain storage by using Merkle proofs instead of storing all eligible addresses
- **Secure**: Leverages OpenZeppelin's battle-tested libraries for cryptographic operations

### Core Contracts

#### MerkleAirdrop.sol

The main airdrop contract that handles token distribution.

**Key Components:**
- `i_merkleRoot`: Immutable Merkle root containing all eligible claims
- `i_airdropToken`: The ERC20 token being distributed
- `s_claimed`: Mapping to track addresses that have already claimed

**Functions:**
- `claim(address account, uint256 amount, bytes32[] merkleProof, uint8 v, bytes32 r, bytes32 s)`: Claims tokens with Merkle proof and signature verification
- `getMessageHash(address account, uint256 amount)`: Returns EIP-712 typed data hash for signing
- `getMerkleRoot()`: Returns the Merkle root
- `getAirdropToken()`: Returns the airdrop token address

**Workflow:** //Follows CEI pattern 
1. Validates the user has not already claimed
2. Verifies the EIP-712 signature matches the account
3. Verifies the Merkle proof against the stored root
4. Marks the account as claimed
5. Transfers tokens to the account

#### BasicToken.sol

A simple ERC20 token contract with minting and burning capabilities.

**Features:**
- Ownable: Only owner can mint and burn
- Standard ERC20 implementation
- Used as the airdrop token for testing and deployment

## Technical Details

### EIP-712 Implementation

The contract uses EIP-712 for structured data signing, which provides:
- Human-readable signatures in wallets
- Protection against signature replay attacks across different domains
- Type-safe message signing

**Domain Separator:**
- Name: "MerkleAirdrop"
- Version: "1"

**Typed Data Structure:**
```solidity
struct AirdropClaim {
    address account;
    uint256 amount;
}
```

### Merkle Tree Structure

The Merkle tree is constructed with:
- **Leaf nodes**: `keccak256(bytes.concat(keccak256(abi.encode(account, amount))))`
- Double hashing prevents second preimage attacks
- Standard OpenZeppelin MerkleProof library for verification

## Usage

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Deploy

```bash
forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Claiming Tokens

To claim tokens, users need:
1. Their allocated amount
2. A Merkle proof proving their eligibility
3. A signature authorizing the claim

**Example claim flow:**

```solidity
// Off-chain: User signs the claim message
bytes32 digest = merkleAirdrop.getMessageHash(userAddress, claimAmount);
(uint8 v, bytes32 r, bytes32 s) = signMessage(digest, userPrivateKey);

// On-chain: Anyone can submit the claim with the signature
merkleAirdrop.claim(userAddress, claimAmount, merkleProof, v, r, s);
```

### Generating Merkle Tree

Use the provided scripts to generate the Merkle tree:

```bash
forge script script/MakeMerkle.s.sol
```

This will generate the Merkle root and proofs for eligible addresses.

## Security Considerations

### Implemented Protections

- **Signature Verification**: ECDSA signature validation ensures only the eligible user authorized the claim
- **Proof Verification**: Merkle proofs prevent unauthorized claims
- **Replay Protection**: Each address can only claim once
- **SafeERC20**: Protects against non-standard ERC20 implementations
- **Domain Separation**: EIP-712 prevents cross-contract signature reuse

### Potential Attack Vectors

- **Front-running**: Since claims are public, transactions could be front-run. The signature verification mitigates this by ensuring only valid signatures are accepted.
- **Merkle Tree Generation**: The off-chain Merkle tree generation must be done correctly. Errors in tree construction will prevent legitimate claims.

## Testing

The test suite covers:
- Successful claim scenarios
- Signature verification
- Merkle proof validation
- Double-claim prevention
- Gas payer functionality (meta-transactions)

Run tests with:
```bash
forge test -vvv
```

## Gas Optimization

The contract is optimized for gas efficiency:
- Immutable variables for fixed values
- Minimal storage usage with Merkle proofs
- Single storage write per claim
- Efficient SafeERC20 usage

## Dependencies

- **OpenZeppelin Contracts**: Industry-standard implementations for ERC20, ECDSA, MerkleProof, and EIP712
- **Forge Standard Library**: Testing utilities
- **Foundry DevOps**: Chain detection and deployment helpers
- **Murky**: Merkle tree generation utilities

## License

MIT

## Author

Illia Verbanov (illiaverbanov.xyz)

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.24

### Installation

```bash
git clone <repository-url>
cd foundry
forge install
```

### Running Tests

```bash
forge test
```

### Deploying

Update the Merkle root in `DeployMerkleAirdrop.s.sol` with your generated root, then run:

```bash
forge script script/DeployMerkleAirdrop.s.sol --rpc-url <rpc-url> --broadcast
```
