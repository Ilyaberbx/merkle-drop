//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
@title MerkleAirdrop (Merke proofs airdrop contract)
@notice A contract that allows users to claim airdrop tokens using Merkle proofs
@dev This contract is used to allow users to claim airdrop tokens using Merkle proofs and allows to verify the signature of the user so first user can claim for second user.
 This functionality is possible because of EIP712 typed data.
@author Illia Verbanov (illiaverbanov.xyz)
*/
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
    event Claim(address indexed account, uint256 amount);

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address => bool) private s_claimed;
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /**
    @notice Claims airdrop tokens using Merkle proofs
    @param account The address of the account to claim tokens for
    @param amount The amount of tokens to claim
    @param merkleProof The Merkle proof to verify
    @param v The v component of the signature
    @param r The r component of the signature
    @param s The s component of the signature
    */
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bool isClaimed = s_claimed[account];

        if (isClaimed) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );

        bool isValid = MerkleProof.verify(merkleProof, i_merkleRoot, leaf);

        if (!isValid) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_claimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /**
    @notice Gets the Merkle root of bytes32 type
    @return The Merkle root of bytes32 type
    */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /**
    @notice Gets the airdrop token of IERC20 standard type
    @return The airdrop token of IERC20 standard type
    */
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    /**
    @notice Gets the message hash of the airdrop claim
    @param account The address of the account to claim tokens for
    @param amount The amount of tokens to claim
    @return The message hash of the airdrop claim of bytes32 type
    @dev This method uses EIP712 typed data to hash the message
    */
    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(MESSAGE_TYPEHASH, AirdropClaim(account, amount))
                )
            );
    }

    /**
    @notice Checks if the signature is valid
    @param account The address of the account to claim tokens for
    @param digest The digest to verify
    @param v The v component of the signature
    @param r The r component of the signature
    @param s The s component of the signature
    @return True if the signature is valid, false otherwise
    @dev This method uses ECDSA library to safely verify the signature
    */
    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address recovered, , ) = ECDSA.tryRecover(digest, v, r, s);
        return recovered == account;
    }
}
