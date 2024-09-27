# ERC5D

**ERC5D** is a new standard based on the [ERC4D standard](https://ethereum-magicians.org/t/erc-4d-dimensional-token-standard-dts/21185), offering significant optimizations that reduce gas fees during the launch process. With Uniswap V3 integration and a fixed `tokenURI` mechanism, ERC5D improves upon the deployment experience by focusing on gas efficiency, proper image handling for NFTs, and reduced costs.

## Optimized Gas Fees

By optimizing initialization and leveraging Uniswap V3, ERC5D reduces gas costs during deployment. Critical operations like `_setERC721TransferExempt` are handled directly in the constructor, saving on post-deployment gas.

```solidity
constructor(
   string memory name_, // Name for ERC-20 representation
   string memory symbol_, // Symbol for ERC-20 representation
   uint8 decimals_, // Decimals for ERC-20 representation
   uint256 supply721_, // Supply of ERC721s to mint (eg. 10000)
   ERC6551Registry registry_, // Registry for 6551 accounts
   ERC6551Account implementation_, // Implementation for 6551 accounts
   bytes32 salt_ // Salt for 6551 accounts (eg. keccak256("ERC5D"))
) ERC4D(name_, symbol_, decimals_) Ownable(_msgSender()) {
   _setERC721TransferExempt(address(this), true);
   _setERC721TransferExempt(_msgSender(), true);

   setup.push(dddd_setup({implementation: implementation_, registry: registry_, salt: salt_}));

   _mintERC20(_msgSender(), supply721_ * units);
   maxWallet = erc20TotalSupply() / 100;
}
```

This approach ensures lower gas usage compared to alternatives that initialize features post-deployment.

## Uniswap V3 Integration

A major improvement in ERC5D is the integration of **Uniswap V3**. The transition from Uniswap V2 to V3 offers better liquidity management and lower gas fees, further enhancing the cost-efficiency of the deployment.

## How to Launch ERC5D Token

To successfully launch an **ERC5D** token, follow the detailed steps below. These steps involve deploying the required **ERC6551** contracts, setting the necessary exemptions, and launching the token.

### Step-by-Step Deployment Guide

1. **Deploy ERC6551 Contracts**:

   First, deploy the following two smart contracts from the `libs` folder:

   - `ERC6551Registry`
   - `ERC6551Account`

   These contracts are necessary for managing **ERC721** token setups and accounts.

2. **Deploy ERC5D Contract**:

   After deploying the ERC6551 contracts, you can deploy the **ERC5D** token contract with the following parameters:

   - `name`: The name of your ERC5D token.
   - `symbol`: The token symbol.
   - `decimals`: The number of decimals (typically `18` for ERC-20 tokens).
   - `supply721`: The total supply of the ERC721 tokens.
   - `registry`: The deployed `ERC6551Registry` contract.
   - `implementation`: The deployed `ERC6551Account` contract.
   - `salt`: A random salt value to ensure the uniqueness of the deployment (this can be generated [here](https://emn178.github.io/online-tools/keccak_256.html)).

3. **Transfer Ownership of ERC6551Registry**:

   Once the contracts are deployed, transfer the ownership of the `ERC6551Registry` contract to the newly deployed `ERC5D` contract:

   ```solidity
   registry.transferOwnership(address(erc5d));
   ```

4. **Set Up Exemptions Using Tenderly**:

   Before adding liquidity, head to the Tenderly dashboard and simulate the creation of the Uniswap V3 pool to get the correct pool address:

   - Open the following link: [Tenderly Simulator](https://dashboard.tenderly.co/impredmet/project/simulator/628e6764-1dd2-4dca-a509-68868635612b)
   - Click on **Re-Simulate**.
   - Enter your `ERC5D` contract address in the **TokenA** field.
   - **Note:** If you change the fee value (e.g., using `3000` instead of `10000`), you must use the same fee value when creating the Uniswap pool in Step 5.
   - Simulate the transaction to get the pool address.

   Once you have the pool address, set it as exempt in the **ERC5D** contract:

   ```solidity
   erc5d.setERC721TransferExempt(poolAddress, true);
   ```

5. **Provide Liquidity on Uniswap**:

   Now that the pool is set up, you can provide liquidity on Uniswap. Head over to the Uniswap V3 interface:

   [Uniswap V3 Pool Creation](https://app.uniswap.org/pool)

   - Select your **ERC5D** token as one of the pair assets (the other can be **ETH** or any other token of your choice).
   - **Important:** Make sure to use the same fee value that was set during the simulation in Step 4 (e.g., if you set `10000`, this corresponds to a `1%` fee tier).
   - Configure the pool parameters based on your preferences.

6. **Update TokenURI**:

   Before launching the token, set the base `tokenURI` for the NFTs. This ensures that the image URLs are properly referenced when queried:

   ```solidity
   erc5d.updateURI("https://memento.build/nfts/");
   ```

7. **Launch the Token**:

   Finally, after adding liquidity and setting the `tokenURI`, you can launch the token by calling the `launch()` function:

   ```solidity
   erc5d.launch();
   ```

8. **Remove Max Wallet Limit (Optional)**:

   If you want to remove the maximum wallet limit restriction for your ERC5D token, you can call the `removeLimits()` function:

   ```solidity
   erc5d.removeLimits();
   ```

   This will set the `maxWallet` to the total supply, allowing unrestricted transfers for all holders.

After completing these steps, your **ERC5D** token is fully deployed, liquidity is provided, and the token is ready for public trading with Uniswap V3 integration.

## Conclusion

ERC5D is an optimized, gas-efficient solution leveraging the latest Uniswap V3 features for better liquidity management and reduced deployment costs. It improves upon the ERC4D standard, making it ideal for those looking for an optimized, lower-fee launch process.
