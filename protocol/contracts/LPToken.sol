// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    address public immutable crowdfundPool;

    modifier onlyPool() {
        require(msg.sender == crowdfundPool, "Only pool can mint/burn");
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        crowdfundPool = msg.sender;
    }

    function mint(address to, uint256 amount) external onlyPool {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyPool {
        _burn(from, amount);
    }
}
