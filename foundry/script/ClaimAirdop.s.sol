// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdop is Script {
    uint256 private constant AMOUNT_TO_CLAIM = 25 * 1e18;
    address private constant USER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32[] private s_proof = [
        bytes32(
            0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad
        ),
        bytes32(
            0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576
        )
    ];
    uint256 private constant USER_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    bytes private constant SIGNATURE =
        hex"12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c438cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca1c";

    function run() external {
        address mostRecent = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claim(mostRecent);
    }

    function claim(address deployedAirdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(deployedAirdrop).claim(
            USER,
            AMOUNT_TO_CLAIM,
            s_proof,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }

    function splitSignature(
        bytes memory signature
    ) private pure returns (uint8, bytes32, bytes32) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 96)))
        }

        return (v, r, s);
    }
}
