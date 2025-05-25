# Smart Contracts

```tree
├── CrowdfundPool.sol         # Individual campaign contract
├── CrowdfundFactory.sol      # Pool deployment factory
├── LPToken.sol              # ERC-20 LP tokens for contributors
├── interfaces/
│   ├── IProtocol.sol        # M3tering Protocol interface
│   ├── IERC6551Registry.sol # TBA registry interface
│   └── IERC6551Account.sol  # TBA account interface
```

## Key Features

### 🎯 **LP Token-Based Crowdfunding**

- Contributors receive LP tokens representing their stake
- Proportional revenue sharing based on token holdings
- Flexible claim mechanism for both refunds and rewards

### 💰 **M3TER NFT Revenue Integration**

- Each campaign receives M3TER NFT for revenue generation
- Automatic revenue accumulation in Token Bound Accounts
- Claimable rewards distributed to LP token holders

### 🔧 **Flexible Pool Management**

- Configurable funding goals and deadlines
- Multiple pool status states (Active, Successful, Failed)
- Emergency refund mechanisms for failed campaigns

### 🛡️ **Security & Risk Management**

- Reentrancy protection on all value transfers
- Pausable functionality for emergency stops
- Creator-controlled emergency refund system
- Proportional risk distribution among contributors

## Getting Started

### Prerequisites

- Node.js >= 16.0.0
- Hardhat or Foundry
- MetaMask or compatible wallet

### Installation

```bash
# Clone the repository
git clone https://github.com/Emmo00/crowdfund-sun-project.git
cd crowdfund-sun-project

# Install dependencies
npm install

# Compile contracts
npx hardhat compile
```

### Deployment

```bash
# Deploy factory contract
npx hardhat run scripts/deployFactory.js --network localhost

# Deploy to testnet
npx hardhat run scripts/deployFactory.js --network goerli
```

## Usage

### For Project Creators

1. **Launch a Campaign**

   ```javascript
   // Deploy through factory
   const tx = await factory.createPool(
     "Project Name",
     "Project Description",
     ethers.utils.parseEther("100"), // 100 ETH goal
     Math.floor(Date.now() / 1000) + 2592000 // 30 days
   );
   ```

2. **Attach M3TER NFT**

   ```solidity
   // Transfer M3TER NFT to the pool contract
   // This enables revenue generation
   m3terNFT.safeTransferFrom(creator, poolAddress, tokenId);
   ```

3. **Claim Revenue**
   ```solidity
   // Claim accumulated revenue from M3tering Protocol
   pool.claimNFTRewards();
   ```

### For Contributors

1. **Contribute to Projects**

   ```solidity
   // Send ETH and receive LP tokens
   pool.contribute{value: contributionAmount}();
   ```

2. **Check Investment Status**

   ```javascript
   const info = await pool.getContributorInfo(contributorAddress);
   console.log(`LP Balance: ${info.lpBalance}`);
   console.log(`Claimable ETH: ${info.claimableETH}`);
   ```

3. **Claim Returns**
   ```solidity
   // Claim proportional share (refund or profit)
   pool.claim(lpTokenAmount);
   ```

## Pool Lifecycle

### Active Phase

- Contributors send ETH and receive LP tokens
- Pool accumulates funding toward goal
- M3TER NFT can be attached for revenue generation

### Completion Phase

**Successful Campaign (Goal Reached)**

- Project can claim funds through TBA
- Revenue sharing begins for LP holders
- Contributors can claim proportional rewards

**Failed Campaign (Goal Not Reached)**

- Emergency refund becomes available
- Contributors can claim proportional ETH refunds
- LP tokens are burned during claim process

## Contract Addresses

### Mainnet

- CrowdfundFactory: `TBD`
- Protocol Integration: `TBD`

### Testnet (Goerli)

- CrowdfundFactory: `TBD`
- M3TER NFT: `0x39fb420Bd583cCC8Afd1A1eAce2907fe300ABD02`
- TBA Registry: `0x000000006551c19487814612e58FE06813775758`

## API Reference

### CrowdfundPool Contract

#### Core Functions

- `contribute()` - Send ETH and receive LP tokens
- `claim(uint256 lpAmount)` - Claim proportional ETH share
- `claimNFTRewards()` - Claim M3TER revenue rewards
- `emergencyRefund()` - Enable refunds for failed campaigns

#### View Functions

- `getPoolStatus()` - Get current pool status (Active/Successful/Failed)
- `getPoolInfo()` - Get comprehensive pool information
- `getContributorInfo(address)` - Get contributor's position details
- `getLPTokenPrice(uint256)` - Calculate ETH value of LP tokens

#### Admin Functions

- `emergencyRefund()` - Creator can enable refunds (failed campaigns only)

### CrowdfundFactory Contract

#### Pool Management

- `createPool(...)` - Deploy new crowdfunding pool
- `getPoolsByCreator(address)` - Get creator's pools
- `getAllPools()` - Get all deployed pools
- `getPoolInfo(address)` - Get specific pool details

## LP Token Economics

### Contribution Phase

- **Minting**: 1 LP token per 1 ETH contributed
- **Supply**: Total LP supply equals total ETH contributed

### Revenue Phase

- **Value**: LP token value = Pool ETH balance / Total LP supply
- **Claims**: Burning LP tokens returns proportional ETH share

### Example Calculation

```
Pool Balance: 50 ETH
Total LP Supply: 100 LP tokens
Your LP Balance: 10 LP tokens
Your Claimable ETH: (10 * 50) / 100 = 5 ETH
```

## Development

### Running Tests

```bash
npx hardhat test
```

### Local Development

```bash
# Start local node
npx hardhat node

# Deploy contracts
npx hardhat run scripts/deploy.js --network localhost
```

### Code Coverage

```bash
npx hardhat coverage
```
