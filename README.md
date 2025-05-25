# M3tering Protocol Crowdfund Integration

A decentralized crowdfunding platform that leverages the M3tering Protocol to enable project funding through tokenized meters with automated revenue distribution and LP token-based contribution tracking.

## Overview

This project creates a unique crowdfunding mechanism where:

- Project creators launch campaigns with M3TER NFT integration
- Contributors receive LP tokens representing their funding share
- Projects generate revenue through the M3tering Protocol
- Revenue is distributed to LP token holders proportionally

## Architecture

### Core Components

**CrowdfundPool Contract**

- Individual crowdfunding campaigns with LP token mechanics
- M3TER NFT integration for revenue generation
- Proportional reward distribution to contributors
- Emergency refund mechanisms for failed campaigns

**CrowdfundFactory Contract**

- Deploys and manages multiple crowdfunding pools
- Standardized pool creation and tracking
- Cross-pool analytics and management

**LP Token System**

- ERC-20 tokens representing contribution shares
- 1:1 minting ratio with ETH contributions
- Burnable for proportional ETH claims
- Revenue share calculation based on token holdings

**M3tering Protocol Integration**

- Revenue accumulation through M3TER NFT meters
- TBA-managed fund distribution
- Configurable tariff rates per project
- Automated fee collection and processing

## Roadmap

- [ ] Custom claim module support for cross chain contract
- [ ] Cross-chain deployment support
- [ ] Support deposit of non native tokens by backer of funding pools

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: [docs.m3ter.ing](https://docs.m3ter.ing)
