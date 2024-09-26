# MEMENTO - Optimized Launch with Lower Fees

## Overview
MEMENTO is built on the ERC4D standard, with optimizations that significantly reduce gas fees during the launch process. The `launch()` function has been simplified, and the `allowExempt` feature is enabled by default. This version offers an improved deployment experience compared to INCEPT, with an emphasis on efficiency and reduced costs.

## Optimized Gas Fees
By optimizing how certain features are initialized, MEMENTO reduces gas costs in the launch phase. Operations that were executed post-deployment in INCEPT are now handled upfront. For instance, the `_setERC721TransferExempt` has been included during the contract deployment:

```solidity
constructor(
    string memory name_, 
    string memory symbol_, 
    uint8 decimals_, 
    uint256 supply721_,
    ERC6551Registry registry_, 
    ERC6551Account implementation_, 
    bytes32 salt_
) ERC4D(name_, symbol_, decimals_) Ownable(msg.sender) {
    _setERC721TransferExempt(address(uniswapV2Router_), true);
    _setERC721TransferExempt(address(this), true);

    setup.push(dddd_setup({implementation: implementation_, registry: registry_, salt: salt_}));

    uint256 supply = supply721_ * units;
    _mintERC20(msg.sender, supply);
    maxWallet = supply / 100;
}
```

This approach saves a significant amount of gas compared to INCEPT's launch flow, where some features were initialized after deployment, leading to extra gas usage.

## Comparing with INCEPT
While both projects follow the ERC4D standard, MEMENTO offers a more streamlined launch process:
- **Lower Gas Fees**: By moving more operations to the constructor and minimizing redundant calls, MEMENTO achieves a lower gas consumption during launch.
- **Default Features**: Unlike INCEPT, MEMENTO has `allowExempt` activated from the start, making it easier to use exempt features without waiting for an additional contract call.

Here is a key comparison with INCEPT's launch function:

INCEPT's launch:
```solidity
function launch(uint256 supply721, bool create) external payable onlyOwner {
    require(erc20TotalSupply() == 0, "Already launched");
    _setERC721TransferExempt(address(this), true);
    
    uint256 supply = supply721 * units;
    maxWallet = supply;
    _mintERC20(address(this), supply);

    allowance[address(this)][address(uniswapV2Router_)] = type(uint256).max;
    if(create) {
      uniswapV2Pair = IUniswapV2Factory(uniswapV2Router_.factory()).createPair(address(this), uniswapV2Router_.WETH());
      _setERC721TransferExempt(uniswapV2Pair, true);
    }
    uniswapV2Router_.addLiquidityETH{value: address(this).balance}(address(this), supply, 0, 0, msg.sender, block.timestamp);
    maxWallet = supply / 100;
}
```

MEMENTO simplifies this by reducing overhead and making critical optimizations, lowering the gas needed for deployment.

## How to Deploy MEMENTO

1. **Deploy the contract**: Compile and deploy the `MEMENTO` contract using Foundry.

2. **Set up the Uniswap Pair**: After deployment, call the `setupPair()` function. This will create a liquidity pair for the token with ETH on Uniswap V2.

   Example:
   ```solidity
   setupPair()
   ```

3. **Add Liquidity**: Go to [Uniswap V2](https://app.uniswap.org/pools/v2) and add liquidity for the newly created pair.

4. **Launch the Token**: Once liquidity is added, call the `launch()` function to finalize the token launch.

   Example:
   ```solidity
   launch()
   ```

## Conclusion
MEMENTO offers a more gas-efficient deployment process compared to INCEPT. By optimizing gas costs and simplifying the setup, it's ideal for projects looking to minimize expenses during the launch phase.
