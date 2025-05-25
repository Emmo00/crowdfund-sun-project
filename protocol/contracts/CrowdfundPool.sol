// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./LPToken.sol";
import "./interfaces/IERC6551Registry.sol";
import "./interfaces/IProtocol.sol";
import "./interfaces/IERC6551Account.sol";
import {CrowdfundFactory} from "./CrowdfundFactory.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract CrowdfundPool is ReentrancyGuard, Pausable, IERC721Receiver {
    address public constant TBA_IMPLEMENTATION =
        0xf52d861E8d057bF7685e5C9462571dFf236249cF;
    address public constant TBA_REGISTRY =
        0x000000006551c19487814612e58FE06813775758;
    address public constant M3TER = 0x39fb420Bd583cCC8Afd1A1eAce2907fe300ABD02;
    address public constant PROTOCOL =
        0x39fb420Bd583cCC8Afd1A1eAce2907fe300ABD02; // TODO: Set the correct protocol address

    IProtocol public constant protocol = IProtocol(PROTOCOL);

    CrowdfundFactory public immutable factory;

    uint256 public m3terTokenId;
    address public immutable creator;
    address public immutable protocolAddress;
    string public projectName;
    string public projectDescription;
    uint256 public fundingGoal;
    uint256 public deadline;

    LPToken public lpToken;
    uint256 public totalContributed;
    uint256 public totalWithdrawn;
    bool public fundsWithdrawnToTBA;

    mapping(address => uint256) public contributions;
    address[] public contributors;

    enum PoolStatus {
        Active,
        Successful,
        Failed
    }

    event M3terNFTReceived(address indexed from, uint256 indexed tokenId);
    event Contribution(
        address indexed contributor,
        uint256 amount,
        uint256 lpTokens
    );
    event Claim(
        address indexed contributor,
        uint256 lpTokens,
        uint256 ethAmount
    );
    event FundsWithdrawnToTBA(uint256 amount, address tbaAddress);

    modifier onlyCreator() {
        require(msg.sender == creator, "Not project creator");
        _;
    }

    modifier poolActive() {
        require(block.timestamp < deadline, "Pool deadline passed");
        _;
    }

    constructor(
        address _creator,
        string memory _projectName,
        string memory _projectDescription,
        uint256 _fundingGoal,
        uint256 _deadline
    ) {
        factory = CrowdfundFactory(msg.sender);

        creator = _creator;
        projectName = _projectName;
        projectDescription = _projectDescription;
        fundingGoal = _fundingGoal;
        deadline = _deadline;

        // Create LP token
        lpToken = new LPToken(
            string(abi.encodePacked("LP-", _projectName)),
            string(abi.encodePacked("LP-", _projectName))
        );
    }

    function contribute()
        external
        payable
        nonReentrant
        poolActive
        whenNotPaused
    {
        require(msg.value > 0, "Must contribute more than 0");

        // Track first-time contributors
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;

        // Mint LP tokens (1:1 ratio with ETH)
        lpToken.mint(msg.sender, msg.value);

        emit Contribution(msg.sender, msg.value, msg.value);
    }

    function claim(uint256 lpAmount) external nonReentrant {
        require(lpAmount > 0, "Must claim more than 0");
        require(
            lpToken.balanceOf(msg.sender) >= lpAmount,
            "Insufficient LP tokens"
        );

        // Calculate ETH amount to return
        uint256 ethAmount = getLPTokenPrice(lpAmount);

        require(ethAmount > 0, "No ETH to claim");

        // Burn LP tokens
        lpToken.burn(msg.sender, lpAmount);
        totalWithdrawn += ethAmount;

        // Transfer ETH
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        emit Claim(msg.sender, lpAmount, ethAmount);
    }

    function claimNFTRewards() external nonReentrant whenNotPaused {
        address moduleAddress = address(0); // TODO: Set the correct module address with the claim logic

        if (m3terTokenId == 0) {
            revert("M3ter NFT not attached");
        }

        address tba = getTBAAddress();
        require(tba != address(0), "Invalid TBA address");

        // create data for protocol claim
        bytes memory data = abi.encode(address(this));

        // Execute claim through the TBA
        bytes memory claimCalldata = abi.encodeWithSelector(
            IProtocol.claim.selector,
            moduleAddress,
            data
        );

        // Call the TBA to execute the claim
        bytes memory result = (
            IERC6551Account(tba).execute(
                address(protocol),
                0,
                claimCalldata,
                0 // operation type: CALL
            )
        );

        (bool success, ) = abi.decode(result, (bool, bytes));

        require(success, "TBA reward claim failed");
    }

    function emergencyRefund() external onlyCreator nonReentrant {
        require(
            block.timestamp > deadline && totalContributed < fundingGoal,
            "Refund not available"
        );

        // Allow all LP holders to claim their proportional share
        // This is handled through the normal claim mechanism
        _pause(); // Pause contributions but allow claims
    }

    function getTBAAddress() public view returns (address) {
        return
            IERC6551Registry(TBA_REGISTRY).account(
                TBA_IMPLEMENTATION,
                0x0,
                block.chainid,
                M3TER,
                m3terTokenId
            );
    }

    function getPoolStatus() public view returns (PoolStatus) {
        if (block.timestamp >= deadline) {
            return
                totalContributed >= fundingGoal
                    ? PoolStatus.Successful
                    : PoolStatus.Failed;
        } else {
            return PoolStatus.Active;
        }
    }

    function getPoolInfo()
        external
        view
        returns (
            string memory _projectName,
            string memory _projectDescription,
            uint256 _fundingGoal,
            uint256 _totalContributed,
            uint256 _deadline,
            address _creator,
            uint256 _contributorCount,
            PoolStatus _status
        )
    {
        return (
            projectName,
            projectDescription,
            fundingGoal,
            totalContributed,
            deadline,
            creator,
            contributors.length,
            this.getPoolStatus()
        );
    }

    function getContributorInfo(
        address contributor
    )
        external
        view
        returns (uint256 contribution, uint256 lpBalance, uint256 claimableETH)
    {
        contribution = contributions[contributor];
        lpBalance = lpToken.balanceOf(contributor);

        if (lpBalance > 0 && lpToken.totalSupply() > 0) {
            claimableETH = getLPTokenPrice(lpBalance);
        }

        return (contribution, lpBalance, claimableETH);
    }

    function getLPTokenPrice(
        uint256 lpAmount
    ) public view returns (uint256 ethAmount) {
        uint256 totalSupply = lpToken.totalSupply();
        if (totalSupply == 0) {
            return 0;
        }
        ethAmount = (lpAmount * address(this).balance) / totalSupply;
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(m3terTokenId == 0, "M3ter NFT already attached");
        require(from == address(0), "Cannot send NFTs to this contract");

        m3terTokenId = tokenId;

        emit M3terNFTReceived(from, tokenId);

        return this.onERC721Received.selector;
    }
}
