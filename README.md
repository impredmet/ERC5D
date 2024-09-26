# ERC4Do - Optimized ERC4D Launch with Uniswap V3 and Lower Fees

## Overview

**ERC4Do** is a new standard based on the [ERC4D standard](https://ethereum-magicians.org/t/erc-4d-dimensional-token-standard-dts/21185), offering significant optimizations that reduce gas fees during the launch process. With Uniswap V3 integration, ERC4Do improves upon the deployment experience by focusing on gas efficiency and reduced costs.

## Optimized Gas Fees

By optimizing initialization and leveraging Uniswap V3, ERC4Do reduces gas costs during deployment. Critical operations like `_setERC721TransferExempt` are handled directly in the constructor, saving on post-deployment gas.

```solidity
constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    uint256 supply721_,
    ERC6551Registry registry_,
    ERC6551Account implementation_,
    bytes32 salt_
) ERC4D(name_, symbol_, decimals_) Ownable(_msgSender()) {
    _setERC721TransferExempt(uniswapV3Router, true);
    _setERC721TransferExempt(uniswapV3Router02, true);
    _setERC721TransferExempt(address(this), true);

    setup.push(dddd_setup({implementation: implementation_, registry: registry_, salt: salt_}));

    uint256 supply = supply721_ * units;
    maxWallet = supply;
    _mintERC20(_msgSender(), supply);
}
```

This approach ensures lower gas usage compared to alternatives that initialize features post-deployment.

## Uniswap V3 Integration

A major improvement in ERC4Do is the integration of **Uniswap V3**. The transition from Uniswap V2 to V3 offers better liquidity management and lower gas fees, further enhancing the cost-efficiency of the deployment.

Key feature:

```solidity
address uniswapV3Router = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
address uniswapV3Router02 = address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
```

These addresses connect ERC4Do directly to Uniswap V3, which is configured to handle liquidity and token transfers with reduced gas consumption.

## Comparing to Previous Versions

Compared to previous versions like **INCEPT** or any Uniswap V2-based implementations, ERC4Do offers several advantages:

- **Lower Gas Fees**: By moving critical operations into the constructor and utilizing Uniswap V3, ERC4Do significantly reduces the gas cost during the launch phase.
- **Uniswap V3 Features**: Using V3 allows for more efficient liquidity management, reducing overall deployment costs and making liquidity provisioning easier and cheaper.

## Conclusion

ERC4Do is an optimized, gas-efficient solution leveraging the latest Uniswap V3 features for better liquidity management and reduced deployment costs. It improves upon the ERC4D standard, making it ideal for those looking for an optimized, lower-fee launch process.
