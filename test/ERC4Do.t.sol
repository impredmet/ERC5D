// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC4Do} from "../src/ERC4Do.sol";
import {ERC6551Registry} from "../src/libs/ERC6551Registry.sol";
import {ERC6551Account} from "../src/libs/ERC6551Account.sol";

contract ERC4DoTest is Test {
    ERC4Do erc4do;
    ERC6551Registry registry;
    ERC6551Account implementation;

    address deployer;
    address user1;

    function setUp() public {
        deployer = vm.addr(1);
        user1 = vm.addr(2);
        vm.deal(deployer, 10 ether);
        vm.deal(user1, 10 ether);

        vm.startPrank(deployer);

        registry = new ERC6551Registry();
        implementation = new ERC6551Account();

        erc4do = new ERC4Do(
            "Memento", "MENTO", 18, 10000, registry, implementation, keccak256(abi.encodePacked("MEMENTO"))
        );

        vm.stopPrank();
    }

    function testSelfExemptBeforeAndAfterLaunch() public {
        vm.startPrank(deployer);

        assertTrue(erc4do.erc721TransferExempt(deployer));
        assertTrue(erc4do.erc721TransferExempt(address(erc4do)));

        vm.expectRevert();
        erc4do.setSelfERC721TransferExempt(false);

        erc4do.launch();
        erc4do.setSelfERC721TransferExempt(false);

        assertFalse(erc4do.erc721TransferExempt(deployer));

        vm.stopPrank();
    }

    function testCreateToken() public {
        uint256 totalSupply = erc4do.erc20TotalSupply();

        vm.startPrank(deployer);
        erc4do.transfer(user1, 1 * 10 ** 18);
        vm.stopPrank();

        assertEq(erc4do.erc20BalanceOf(deployer), totalSupply - 1 * 10 ** 18);
        assertEq(erc4do.erc20BalanceOf(user1), 1 * 10 ** 18);
    }

    function testSetUpdateURI() public {
        vm.startPrank(deployer);

        assertEq(erc4do.dataURI(), "");

        string memory newURI = "https://newuri.com/";
        erc4do.updateURI(newURI);

        assertEq(erc4do.dataURI(), newURI);

        vm.stopPrank();
    }

    function testUpdateURI() public {
        vm.startPrank(deployer);

        string memory initialURI = "https://initialuri.com/";
        erc4do.updateURI(initialURI);
        assertEq(erc4do.dataURI(), initialURI);

        string memory updatedURI = "https://updateduri.com/";
        erc4do.updateURI(updatedURI);

        assertEq(erc4do.dataURI(), updatedURI);

        vm.stopPrank();
    }

    function testTransferOwnershipERC6551Registry() public {
        vm.startPrank(deployer);

        registry.transferOwnership(address(erc4do));

        assertEq(registry.owner(), address(erc4do));

        vm.stopPrank();
    }

    function testRenounceOwnershipERC4Do() public {
        vm.startPrank(deployer);

        erc4do.renounceOwnership();

        assertEq(erc4do.owner(), address(0));

        vm.stopPrank();
    }
}
