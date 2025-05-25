// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./CrowdfundPool.sol";
import "./interfaces/IERC6551Registry.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CrowdfundFactory is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public constant TBA_IMPLEMENTATION =
        0xf52d861E8d057bF7685e5C9462571dFf236249cF;
    address public constant TBA_REGISTRY =
        0x000000006551c19487814612e58FE06813775758;
    address public constant M3TER = 0x39fb420Bd583cCC8Afd1A1eAce2907fe300ABD02;

    address[] public allPools;

    event PoolCreated(
        address indexed pool,
        address indexed creator,
        string projectName,
        uint256 fundingGoal,
        uint256 deadline
    );

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function createPool(
        string memory projectName,
        string memory projectDescription,
        uint256 fundingGoal,
        uint256 durationInDays
    ) external nonReentrant returns (address poolAddress) {
        // Calculate deadline
        uint256 deadline = block.timestamp + (durationInDays * 1 days);

        // Create new pool
        CrowdfundPool newPool = new CrowdfundPool(
            msg.sender,
            projectName,
            projectDescription,
            fundingGoal,
            deadline
        );

        poolAddress = address(newPool);

        allPools.push(poolAddress);

        emit PoolCreated(
            poolAddress,
            msg.sender,
            projectName,
            fundingGoal,
            deadline
        );

        return poolAddress;
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    function getPoolCount() external view returns (uint256) {
        return allPools.length;
    }
}
