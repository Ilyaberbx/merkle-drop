//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
@title BasicToken (Ownable ERC20 token)
@notice A contract that mints and burns tokens
@dev This contract is used to mint and burn tokens
@author Illia Verbanov (illiaverbanov.xyz)
*/
contract BasicToken is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable(msg.sender) {}

    /**
    @notice Mints tokens to an address
    @param to The address to mint tokens to
    @param amount The amount of tokens to mint
    */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
    @notice Burns tokens from an address
    @param from The address to burn tokens from
    @param amount The amount of tokens to burn
    */
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
