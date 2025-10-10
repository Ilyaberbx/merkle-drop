//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BasicToken} from "../src/BasicToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private constant ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 private constant AMOUNT_TO_TRANSFER = 4 * 25 * 1e18;

    function run() public {
        execute();
    }

    function execute() public returns (MerkleAirdrop, BasicToken) {
        vm.startBroadcast();
        BasicToken basicToken = new BasicToken("BasicToken", "BASIC");
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(
            ROOT,
            IERC20(address(basicToken))
        );
        basicToken.mint(basicToken.owner(), AMOUNT_TO_TRANSFER);
        basicToken.transfer(address(merkleAirdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (merkleAirdrop, basicToken);
    }
}
