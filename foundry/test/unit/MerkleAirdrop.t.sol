//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BasicToken} from "../../src/BasicToken.sol";
import {ZkSyncChainChecker} from "../../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    bytes32 private constant ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 private constant AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;

    MerkleAirdrop s_merkleAirdrop;
    BasicToken s_basicToken;
    address user;
    uint256 userPrivateKey;
    address gasPayer;
    bytes32[] private s_proof = [
        bytes32(
            0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a
        ),
        bytes32(
            0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576
        )
    ];

    function setUp() public {
        (user, userPrivateKey) = makeAddrAndKey("user");
        (gasPayer) = makeAddr("gasPayer");
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (s_merkleAirdrop, s_basicToken) = deployer.execute();
            return;
        }
        s_basicToken = new BasicToken("BasicToken", "BASIC");
        s_merkleAirdrop = new MerkleAirdrop(ROOT, s_basicToken);
        s_basicToken.mint(s_basicToken.owner(), AMOUNT_TO_MINT);
        s_basicToken.transfer(address(s_merkleAirdrop), AMOUNT_TO_MINT);
    }

    function testUsersCanClaim() public {
        uint256 staringBalance = s_basicToken.balanceOf(user);
        assertEq(staringBalance, 0);

        bytes32 digest = s_merkleAirdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(gasPayer);
        s_merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, s_proof, v, r, s);

        uint256 endingBalance = s_basicToken.balanceOf(user);
        console.log("Ending Balance: ", endingBalance);
        assertEq(endingBalance, staringBalance + AMOUNT_TO_CLAIM);
    }
}
