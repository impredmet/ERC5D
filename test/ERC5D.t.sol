// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC5D} from "../src/ERC5D.sol";
import {ERC6551Registry} from "../src/libs/ERC6551Registry.sol";
import {ERC6551Account} from "../src/libs/ERC6551Account.sol";

contract ERC5DTest is Test {
    ERC5D erc5d;
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

        erc5d = new ERC5D("Test", "TEST", 18, 10000, registry, implementation, keccak256(abi.encodePacked("TEST")));

        vm.stopPrank();
    }

    function testSelfExemptBeforeAndAfterLaunch() public {
        vm.startPrank(deployer);

        assertTrue(erc5d.erc721TransferExempt(deployer));
        assertTrue(erc5d.erc721TransferExempt(address(erc5d)));

        vm.expectRevert();
        erc5d.setSelfERC721TransferExempt(false);

        erc5d.launch();
        erc5d.setSelfERC721TransferExempt(false);

        assertFalse(erc5d.erc721TransferExempt(deployer));

        vm.stopPrank();
    }

    function testCreateToken() public {
        uint256 totalSupply = erc5d.erc20TotalSupply();

        vm.startPrank(deployer);
        erc5d.transfer(user1, 1 * 10 ** 18);
        vm.stopPrank();

        assertEq(erc5d.erc20BalanceOf(deployer), totalSupply - 1 * 10 ** 18);
        assertEq(erc5d.erc20BalanceOf(user1), 1 * 10 ** 18);
    }

    function testSetUpdateURI() public {
        vm.startPrank(deployer);

        assertEq(erc5d.dataURI(), "");

        string memory newURI = "https://newuri.com/";
        erc5d.updateURI(newURI);

        assertEq(erc5d.dataURI(), newURI);

        vm.stopPrank();
    }

    function testUpdateURI() public {
        vm.startPrank(deployer);

        string memory initialURI = "https://initialuri.com/";
        erc5d.updateURI(initialURI);
        assertEq(erc5d.dataURI(), initialURI);

        string memory updatedURI = "https://updateduri.com/";
        erc5d.updateURI(updatedURI);

        assertEq(erc5d.dataURI(), updatedURI);

        vm.stopPrank();
    }

    function testTransferOwnershipERC6551Registry() public {
        vm.startPrank(deployer);

        registry.transferOwnership(address(erc5d));

        assertEq(registry.owner(), address(erc5d));

        vm.stopPrank();
    }

    function testRenounceOwnershipERC5D() public {
        vm.startPrank(deployer);

        erc5d.renounceOwnership();

        assertEq(erc5d.owner(), address(0));

        vm.stopPrank();
    }
}
