// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {ERC5D} from "../src/ERC5D.sol";
import {ERC6551Registry} from "../src/libs/ERC6551Registry.sol";
import {ERC6551Account} from "../src/libs/ERC6551Account.sol";

contract ERC5DScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ERC6551Registry registry = new ERC6551Registry();
        ERC6551Account implementation = new ERC6551Account();

        string memory name = "Memento";
        string memory symbol = "MENTO";
        uint8 decimals = 18;
        uint256 supply721 = 10_000;
        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));

        new ERC5D(name, symbol, decimals, supply721, registry, implementation, salt);

        vm.stopBroadcast();
    }
}
