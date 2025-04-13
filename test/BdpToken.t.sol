// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BDPToken.sol";

contract BDPTokenTest is Test {
    BDPToken public token;
    address owner = address(0x123);
    address user1 = address(0x456);
    uint256 constant INITIAL_SUPPLY = 10000 * 10**18;
    uint256 constant MAX_MINT = 1000 * 10**18;

    function setUp() public {
        vm.prank(owner);
        token = new BDPToken();
    }

    function testMint() public {
        vm.warp(block.timestamp + 1 days); // Simulate a new day
        vm.prank(user1);
        token.mint(MAX_MINT);
        assertEq(token.balanceOf(user1), MAX_MINT, "User should have received minted tokens");
    }

    function testMintExceedsLimit() public {
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(user1);
        token.mint(MAX_MINT);
        vm.expectRevert("Mint limit exceeded for today");
        token.mint(1);
        vm.stopPrank();
    }

    function testMintResetsDailyLimit() public {
        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        token.mint(MAX_MINT);

        vm.warp(block.timestamp + 1 days); // Simulate next day
        vm.prank(user1);
        token.mint(MAX_MINT);
        assertEq(token.balanceOf(user1), MAX_MINT * 2, "User should be able to mint again next day");
    }

    function testNonOwnerCannotMintExcess() public {
        vm.prank(user1);
        vm.expectRevert("Exceeds max mint per day");
        token.mint(MAX_MINT + 1);
    }
}
